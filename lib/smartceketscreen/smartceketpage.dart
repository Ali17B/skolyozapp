import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';

class BluetoothManager {
  BluetoothConnection? connection;

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await FlutterBluetoothSerial.instance.getBondedDevices();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    connection = await BluetoothConnection.toAddress(device.address);
  }

  void sendData(String message) {
    if (connection != null) {
      connection!.output.add(Uint8List.fromList(utf8.encode(message + '\r\n')));
    }
  }

  Stream<Uint8List>? get onDataReceived => connection?.input;

  void dispose() {
    connection?.close();
  }
}

class CeketPage extends StatefulWidget {
  const CeketPage({Key? key}) : super(key: key);

  @override
  _CeketPageState createState() => _CeketPageState();
}

class _CeketPageState extends State<CeketPage> {
  final bluetoothManager = BluetoothManager();
  bool isConnected = false;
  bool isConnecting = false;
  Map<String, double> deviceAngles = {};
  Timer? updateTimer;

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions();
    _connectToBluetoothDevice();
    updateTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (isConnected) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    updateTimer?.cancel();
    bluetoothManager.dispose();
    super.dispose();
  }

  void _connectToBluetoothDevice() async {
    setState(() => isConnecting = true);
    try {
      List<BluetoothDevice> devices = await bluetoothManager.getBondedDevices();
      BluetoothDevice? hc05 =
          devices.firstWhereOrNull((device) => device.name == 'HC-05');

      if (hc05 == null) {
        setState(() {
          isConnecting = false;
        });
        throw Exception('HC-05 cihazı bulunamadı.');
      }

      await bluetoothManager.connectToDevice(hc05);
      bluetoothManager.onDataReceived?.asBroadcastStream().listen((data) {
        _processData(utf8.decode(data));
      });
      setState(() {
        isConnected = true;
        isConnecting = false;
      });
    } catch (e) {
      _showErrorDialog('Bluetooth cihazına bağlanılamadı. Hata: $e');
      setState(() => isConnecting = false);
    }
  }

  void _processData(String rawData) {
    List<String> lines = rawData.trim().split('\n');
    Map<String, double> tempDeviceAngles = {};

    for (var line in lines) {
      if (line.startsWith('D')) {
        var parts = line.split(' ');
        var deviceId = parts[0];
        var angle = double.tryParse(parts[1]);
        if (angle != null) {
          tempDeviceAngles[deviceId] = angle;
        }
      }
    }

    setState(() {
      deviceAngles = tempDeviceAngles;
    });
  }

  Future<void> _requestBluetoothPermissions() async {
    if (!await Permission.bluetoothConnect.request().isGranted) {
      _showErrorDialog('Bluetooth bağlantı izni verilmedi.');
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hata'),
          content: Text(error),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  String _checkSkolyoz() {
    bool condition1 = _isInRange(
        (deviceAngles['D6'] ?? 0) + (deviceAngles['D7'] ?? 0), 175, 185);
    bool condition2 = _isInRange(deviceAngles['D5'] ?? 0, 355, 5);
    bool condition3 = _isInRange(deviceAngles['D7'] ?? 0, 355, 5);

    if (condition1 && condition2 && condition3) {
      return 'Kişi sağlıklı, skolyoz tespit edilemedi';
    } else if (condition1 && condition2 && !condition3) {
      return 'Kalça bölgesi skolyoz varlığı';
    } else if (condition1 && !condition2 && condition3) {
      return 'Sırt bölgesi skolyoz varlığı';
    } else if (condition1 && !condition2 && !condition3) {
      return 'Kalça ve Sırt bölgesi skolyoz varlığı';
    } else if (!condition1 && condition2 && condition3) {
      return 'Omuz bölgesi skolyoz varlığı';
    } else if (!condition1 && condition2 && !condition3) {
      return 'Omuz ve kalça bölgesi skolyoz varlığı';
    } else if (!condition1 && !condition2 && condition3) {
      return 'Omuz ve sırt bölgesi skolyoz varlığı';
    } else {
      return 'Omuz, sırt ve kalça bölgesi skolyoz varlığı';
    }
  }

  bool _isInRange(double value, double min, double max) {
    if (min < max) {
      return value >= min && value <= max;
    } else {
      return value >= min || value <= max;
    }
  }

  double _calculateAverage(double angle1, double angle2) {
    return (angle1 + angle2) / 2;
  }

  Color _darken(Color color, [double amount = .1]) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Widget _buildTabContent(
      String title,
      String imagePath,
      List<String> measurementData,
      String resultTitle,
      String result,
      Color resultColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 200),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Column(
              children: measurementData
                  .map((data) => Text(data,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))
                  .toList(),
            ),
          ),
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: resultColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _darken(resultColor)),
            ),
            child: Column(
              children: [
                Text(resultTitle,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(result, style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Smart Ceket'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'KİFOZ'),
              Tab(text: 'LORDOZ'),
              Tab(text: 'SKOLYOZ'),
            ],
          ),
        ),
        body: isConnected
            ? TabBarView(
                children: [
                  _buildTabContent(
                      'Kifoz',
                      'assets/images/kifoz.jpeg',
                      [
                        '1. sensör grubu: ${(deviceAngles['D1'] ?? 0).toStringAsFixed(2)}°',
                        '2. sensör grubu: ${(deviceAngles['D2'] ?? 0).toStringAsFixed(2)}°'
                      ],
                      'TKA',
                      _calculateAverage((deviceAngles['D1'] ?? 0),
                              (deviceAngles['D2'] ?? 0))
                          .toStringAsFixed(2),
                      Colors.blue[100]!),
                  _buildTabContent(
                      'Lordoz',
                      'assets/images/lordoz.jpeg',
                      [
                        '1. sensör grubu: ${(deviceAngles['D4'] ?? 0).toStringAsFixed(2)}°',
                        '2. sensör grubu: ${(deviceAngles['D5'] ?? 0).toStringAsFixed(2)}°'
                      ],
                      'LLA',
                      _calculateAverage((deviceAngles['D4'] ?? 0),
                              (deviceAngles['D5'] ?? 0))
                          .toStringAsFixed(2),
                      Colors.blue[100]!),
                  _buildTabContent(
                      'Skolyoz',
                      'assets/images/skolyoz.jpeg',
                      [
                        'x1+x2: ${(deviceAngles['D6'] ?? 0) + (deviceAngles['D7'] ?? 0)}°',
                        'y1: ${(deviceAngles['D5'] ?? 0).toStringAsFixed(2)}°',
                        'z1: ${(deviceAngles['D7'] ?? 0).toStringAsFixed(2)}°'
                      ],
                      'Açıklama',
                      _checkSkolyoz(),
                      Colors.blue[100]!),
                ],
              )
            : Center(
                child: isConnecting
                    ? CircularProgressIndicator()
                    : Text('Cihaza bağlanılıyor...'),
              ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CeketPage(),
  ));
}
