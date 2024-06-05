import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  FlutterBlue ble = FlutterBlue.instance;
  final _scanResults = <ScanResult>[].obs;

  @override
  void onInit() {
    super.onInit();
    ble.scanResults.listen((results) {
      _scanResults.assignAll(results);
    });
  }

  Future<void> scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      if (await Permission.bluetoothConnect.request().isGranted) {
        ble.startScan(timeout: const Duration(seconds: 15));
        await Future.delayed(
            const Duration(seconds: 15)); // Ensure scan runs for 15 seconds
        ble.stopScan();
      }
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    print(device);
    await device.connect(timeout: const Duration(seconds: 15));

    device.state.listen((isConnected) async {
      if (isConnected == BluetoothDeviceState.connecting) {
        print("Device connecting to: ${device.name}");
      } else if (isConnected == BluetoothDeviceState.connected) {
        print("Device connected: ${device.id}");
        await _discoverServices(device); // Discover services when connected
      } else {
        print("Device Disconnected");
      }
    });
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write) {
          await _writeToCharacteristic(characteristic, "hello");
        }
      }
    }
  }

  Future<void> _writeToCharacteristic(
      BluetoothCharacteristic characteristic, String data) async {
    List<int> bytes = utf8.encode(data); // Convert string to bytes
    await characteristic.write(bytes);
    print("Data written to characteristic: $data");
  }

  Stream<List<ScanResult>> get scanResults => _scanResults.stream;
}
