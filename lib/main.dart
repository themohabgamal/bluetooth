import 'package:blueblue/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pb Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.deepPurple,
        brightness: Brightness.dark,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BLE Scanner"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GetBuilder<BleController>(
          init: BleController(),
          builder: (BleController controller) {
            return Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<ScanResult>>(
                    stream: controller.scanResults,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "No Devices Found",
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final data = snapshot.data![index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.bluetooth,
                                  color: Colors.blue.shade700,
                                ),
                                title: Text(data.device.name.isNotEmpty
                                    ? data.device.name
                                    : "Unknown Device"),
                                subtitle: Text(
                                    "ID: ${data.device.id.id}\nRSSI: ${data.rssi}"),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () =>
                                    controller.connectToDevice(data.device),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "No Devices Found",
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() {
            _isScanning = true;
          });
          await Get.find<BleController>().scanDevices();
          setState(() {
            _isScanning = false;
          });
        },
        child: _isScanning
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.search),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
