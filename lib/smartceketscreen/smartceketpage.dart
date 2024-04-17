import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async'; // Timer

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
  String receivedData = "";
  Timer? _dataTimer;
  String _receivedData = "";

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions();
    _connectToBluetoothDevice();
    _startDataTimer();
  }

  void _connectToBluetoothDevice() async {
    List<BluetoothDevice> devices = await bluetoothManager.getBondedDevices();
    try {
      BluetoothDevice hc06 =
          devices.firstWhere((device) => device.name == 'HC-05');
      await bluetoothManager.connectToDevice(hc06);
      setState(() {
        isConnected = true;
      });
      bluetoothManager.onDataReceived?.asBroadcastStream().listen((data) {
        _receivedData = utf8.decode(data);
      });
    } catch (e) {
      _showErrorDialog('Bluetooth cihazına bağlanılamadı. Hata: $e');
    }
  }

  void _startDataTimer() {
    _dataTimer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      _updateDataDisplay();
    });
  }

  void _updateDataDisplay() {
    setState(() {
      receivedData = _receivedData;
    });
  }

  @override
  void dispose() {
    bluetoothManager.connection?.dispose(); // Bağlantıyı temizle
    _dataTimer?.cancel(); // Timer'ı iptal et
    super.dispose();
  }

  void _showErrorDialog(String error) {
    // Hata mesajını göster
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hata'),
          content: Text(error),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Bluetooth izinlerini isteyen metot
  Future<void> _requestBluetoothPermissions() async {
    if (await Permission.bluetoothConnect.request().isGranted) {
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 250, 0.959),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(245, 245, 250, 0.959),
        title: Text(
          'Smart Ceket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.bluetooth),
            color: isConnected ? Colors.blue : Colors.grey,
            onPressed: isConnected ? null : _connectToBluetoothDevice,
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Eklediğimiz SingleChildScrollView
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[],
              ),
            ),
            SizedBox(height: 30),
            Text("Bluetooth ile Gelen Data:"),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: receivedData
                    .split("\n")
                    .map((String line) => Text(
                          line,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
