import 'dart:convert';
import 'dart:typed_data';
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
  String receivedData = "";

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions();
  }

  // Bluetooth izinlerini isteyen metot
  Future<void> _requestBluetoothPermissions() async {
    if (await Permission.bluetoothConnect.request().isGranted) {
    } else {}
  }

  void _connectToBluetoothDevice() async {
    List<BluetoothDevice> devices = await bluetoothManager.getBondedDevices();
    try {
      BluetoothDevice hc06 =
          devices.firstWhere((device) => device.name == 'HC-06');
      await bluetoothManager.connectToDevice(hc06);
      bluetoothManager.onDataReceived?.listen((data) {
        setState(() {
          receivedData = utf8.decode(data); // Alınan veriyi decode edip sakla
        });
      });

      setState(() {
        isConnected = true;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hata'),
            content: Text('Bluetooth cihazına bağlanılamadı.'),
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
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[],
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: Image.asset('assets/images/ceket.png'),
          ),
          SizedBox(height: 20),
          Text("Bluetooth ile Gelen Data:"),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.only(left: 170, right: 170), 
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2,), 
              borderRadius:
                  BorderRadius.circular(10), 
            ),
            child: Text(receivedData,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
