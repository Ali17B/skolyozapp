import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';
//import 'package:cloud_firestore/cloud_firestore.dart';
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
  Map<String, Map<String, double?>> deviceData =
      {}; // Cihaz verilerini saklamak için

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions();
    _connectToBluetoothDevice();
  }

  void _connectToBluetoothDevice() async {
    setState(() => isConnecting = true);
    try {
      List<BluetoothDevice> devices = await bluetoothManager.getBondedDevices();
      BluetoothDevice? hc06 =
          devices.firstWhereOrNull((device) => device.name == 'HC-05');

      if (hc06 == null) {
        setState(() {
          isConnecting = false;
        });
        throw Exception('HC-05 cihazı bulunamadı.');
      }

      await bluetoothManager.connectToDevice(hc06);
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

  Map<String, double> deviceAngles = {}; // Cihaz açılarını saklamak için

  double calculateAngle(double ay, double ax, double az) {
    if (ax == 0 && az == 0) ax = 0.00000001; // Sıfır bölme hatasını önle
    double m = atan((2 * ay) / sqrt(pow(2 * ax, 2) + pow(2 * az, 2)));
    double angle = m / pi * 180;
    return az < 0 ? angle : 180 - angle;
  }

  void _processData(String rawData) {
    List<String> lines = rawData.trim().split('\n');
    Map<String, Map<String, double?>> tempDeviceData = {};

    for (var line in lines) {
      var parts = line.split(' ');
      var deviceId = parts[0];

      tempDeviceData[deviceId] = deviceData[deviceId] ??
          {
            'Ax': null,
            'Ay': null,
            'Az': null,
            'Gx': null,
            'Gy': null,
            'Gz': null,
            'Temp': null
          };

      Map<String, double?> currentSensors = tempDeviceData[deviceId]!;

      for (var i = 1; i < parts.length; i++) {
        var sensor = parts[i].split(':');
        if (sensor.length == 2) {
          currentSensors[sensor[0]] = double.tryParse(sensor[1]);
        }
      }

      // Açıyı hesapla ve kaydet
      if (currentSensors['Ay'] != null &&
          currentSensors['Ax'] != null &&
          currentSensors['Az'] != null) {
        double angle = calculateAngle(currentSensors['Ay']!,
            currentSensors['Ax']!, currentSensors['Az']!);
        deviceAngles[deviceId] = angle;
      }
    }

    setState(() {
      deviceData = tempDeviceData;
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

  @override
  Widget build(BuildContext context) {
    var sortedKeys = deviceAngles.keys.toList()
      ..sort((a, b) => int.parse(a.replaceAll('Device:', ''))
          .compareTo(int.parse(b.replaceAll('Device:', ''))));

    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Ceket'),
      ),
      body: ListView.builder(
        itemCount: sortedKeys.length,
        itemBuilder: (context, index) {
          String deviceId = sortedKeys[index];
          double angle = deviceAngles[deviceId]!;
          return ListTile(
            title: Text('$deviceId'),
            subtitle: Text('Açı: ${angle.toStringAsFixed(2)} derece'),
          );
        },
      ),
    );
  }
}
