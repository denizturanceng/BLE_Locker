import 'dart:async';
import 'package:ble_locker/Screens/Home.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';


// Define a global variable to store the BluetoothDevice object
BluetoothDevice? connectedDevice;

class Connection extends StatefulWidget {
  static String routeName = 'Connection';

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _Connection();
  }
}

class _Connection extends State<Connection> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  late StreamSubscription scanSubscription;
  List<ScanResult> scanResults = [];
  Color navy = Color.fromARGB(255, 16, 0, 60);


  final String uartServiceUuid = '25eb434a-260c-4df1-a39c-3b87e9c0ccfa';
  final String uartRxCharacteristicUuid = '25eb434b-260c-4df1-a39c-3b87e9c0ccfa';
  final String uartTxCharacteristicUuid = '25eb434c-260c-4df1-a39c-3b87e9c0ccfa';

  @override
  void initState() {
    super.initState();
    ScanDevices();
  }

  void ScanDevices() {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 10));
    // Listen to scan results
    scanSubscription = flutterBlue.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    // Handle errors
    scanSubscription.onError((error) {
      print('Error while scanning: $error');
    });

    // Stop scanning
    Future.delayed(Duration(seconds: 10), () {
      flutterBlue.stopScan();
    });
  }

  @override
  void dispose() {
    scanSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.redAccent, //change your color here
        ),
        title: Text(
          "Connectable Devices",
          style: TextStyle(color: Colors.redAccent, fontSize: 25),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "You must turn on bluetooth and location to scan nearby devices.",
              style: TextStyle(color: Colors.redAccent, fontSize: 10),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title:
                  Text("Device name:${scanResults[index].device.name}", style:
                  TextStyle(color:
                  Colors.redAccent)), // Set the text color to redAccent),
                  subtitle:
                  Text('Device id:${scanResults[index].device.id}', style:
                  TextStyle(color:
                  navy)),
                  onTap:
                      () {
                    showDialog(
                      context:
                      context,
                      builder:
                          (BuildContext context) {
                        return AlertDialog(
                          title:
                          Text('Connect to ${scanResults[index].device.name} ?'),
                          content:
                          Text('Are you sure you want to connect to ${scanResults[index].device.name} ?'),
                          actions:
                          <Widget>[
                            FilledButton(
                              child:
                              Text('Yes'),
                              style:
                              ButtonStyle(backgroundColor:
                              MaterialStateProperty.all(Colors.redAccent)),
                              onPressed:
                                  () async {
                                Navigator.pushNamed(context,
                                    Home.routeName);
                                await scanResults[index].device.connect();
                                Fluttertoast.showToast(
                                    msg:
                                    "Connected",
                                    toastLength:
                                    Toast.LENGTH_SHORT,
                                    gravity:
                                    ToastGravity.CENTER,
                                    timeInSecForIosWeb:
                                    1,
                                    backgroundColor:
                                    Colors.redAccent,
                                    textColor:
                                    navy,
                                    fontSize:
                                    16.0);
                                //print('Connected to ${scanResults[index].device.name}');

                                // Store the BluetoothDevice object in the global variable
                                connectedDevice = scanResults[index].device;


                                // Discover all services and characteristics for the connected device
                                List<BluetoothService> services =
                                await scanResults[index].device.discoverServices();
                                services.forEach((service) {
                                  // Find the UART Service
                                  if (service.uuid.toString() == uartServiceUuid) {
                                    service.characteristics.forEach((characteristic) async {
                                      // Find the TX Characteristic
                                      if (characteristic.uuid.toString() ==
                                          uartTxCharacteristicUuid) {

                                        // Set up notifications for the TX Characteristic
                                        characteristic.setNotifyValue(true);
                                        characteristic.value.listen((value) async {

                                        print(value.last);
                                        });
                                      }
                                      else if(characteristic.uuid.toString() == uartRxCharacteristicUuid){
                                        List<int> trigger_value_list = [10,20,30];
                                        await characteristic.write(trigger_value_list);
                                        Fluttertoast.showToast(
                                            msg: "Trigger sent to ESP32",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.redAccent,
                                            textColor: navy,
                                            fontSize: 16.0);
                                      }
                                    });
                                  }
                                });
                              },
                            ),
                            FilledButton(
                              child:
                              Text('No'),
                              style:
                              ButtonStyle(backgroundColor:
                              MaterialStateProperty.all(Colors.redAccent)),
                              onPressed:
                                  () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }, // Set the text color to redAccent),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}