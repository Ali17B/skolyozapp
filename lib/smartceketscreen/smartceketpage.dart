import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Map<String, double> deviceAngles = {};

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions();
    _connectToBluetoothDevice();
  }

  void _connectToBluetoothDevice() async {
    try {
      List<BluetoothDevice> devices = await bluetoothManager.getBondedDevices();
      BluetoothDevice hc06 =
          devices.firstWhere((device) => device.name == 'HC-05');
      await bluetoothManager.connectToDevice(hc06);
      bluetoothManager.onDataReceived?.asBroadcastStream().listen((data) {
        _processData(utf8.decode(data));
      });
      setState(() => isConnected = true);
    } catch (e) {
      _showErrorDialog('Bluetooth cihazına bağlanılamadı. Hata: $e');
    }
  }

  void _processData(String rawData) {
    List<String> lines = rawData.split("\n");
    Map<String, double> newAngles = {};
    for (String line in lines) {
      if (line.startsWith("Device")) {
        String deviceId = line.split(':')[0];
        Map<String, double> sensors = {};
        var sensorData = line.split(':')[1].trim().split(' ');
        sensorData.forEach((element) {
          var keyValue = element.split(':');
          sensors[keyValue[0]] = double.parse(keyValue[1]);
        });

        double ax = sensors['Ax'] ?? 0.0;
        double ay = sensors['Ay'] ?? 0.0;
        double az = sensors['Az'] ?? 0.0;
        if (ax == 0.0 && az == 0.0) ax = 0.00000001;
        double angle = calculateAngle(ay, ax, az);
        newAngles[deviceId] = angle;
      }
    }
    setState(() {
      deviceAngles = newAngles;
    });

// Hesaplanan açı değerlerini Firestore'a kaydettik
    saveAngleDataToFirestore(deviceAngles);
  }

  double calculateAngle(double ay, double ax, double az) {
    double m = atan((2 * ay) / sqrt(pow(2 * ax, 2) + pow(2 * az, 2)));
    double angle = m / pi * 180;
    return az < 0 ? angle : 180 - angle;
  }

  @override
  void dispose() {
    bluetoothManager.dispose();
    super.dispose();
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

  // Bluetooth izinlerini isteyen metot
  Future<void> _requestBluetoothPermissions() async {
    if (!await Permission.bluetoothConnect.request().isGranted) {
      // Handle permissions not granted
    } else {}
  }

  void saveAngleDataToFirestore(Map<String, double> deviceAngles) async {
    String userId =
        "kullaniciId"; // Kullanıcının ID'si, kimlik doğrulama durumuna göre ayarlanmalıdır.

    try {
      await FirebaseFirestore.instance
          .collection('kullanicilartable')
          .doc(userId)
          .set({'deviceAngles': deviceAngles}, SetOptions(merge: true));
      print("Açılar başarıyla kaydedildi.");
    } catch (e) {
      print("Firestore'a veri kaydedilirken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Ceket'),
        actions: [
          IconButton(
            icon: Icon(Icons.bluetooth),
            color: isConnected ? Colors.blue : Colors.grey,
            onPressed: isConnected ? null : _connectToBluetoothDevice,
          ),
        ],
      ),
      body: ListView(
        children: deviceAngles.entries.map((entry) {
          return ListTile(
            title: Text('${entry.key}'),
            subtitle: Text('Açı: ${entry.value.toStringAsFixed(2)} derece'),
          );
        }).toList(),
      ),
    );
  }
}
