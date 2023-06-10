import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Connection.dart';
class Home extends StatefulWidget {
  static String routeName = 'Home';
  @override
  State<StatefulWidget> createState() {
    return _Home();
  }
}
class _Home extends State<Home> {
  Color navy = Color.fromRGBO(3, 2, 56, 1);
  String newPassword = "";
  String enteredPassword = "";
  Future <void> SetPassword() async{
    var bytes = utf8.encode(newPassword);
    var digest = sha256.convert(bytes);
    BluetoothDevice? device = connectedDevice;
    if (device != null) {
      // Discover all services and characteristics for the connected device
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) async {
        if (service.uuid.toString() == "25eb434a-260c-4df1-a39c-3b87e9c0ccfa") {
          for (BluetoothCharacteristic characteristic in service
              .characteristics) {
            // do something with characteristic
            if (characteristic.uuid.toString() ==
                "25eb434b-260c-4df1-a39c-3b87e9c0ccfa") {

              List <int> newPasswordHash = utf8.encode("SET") + digest.bytes;

              await characteristic.write(newPasswordHash, withoutResponse: true);
              Fluttertoast.showToast(
                  msg: "New password has been set.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.redAccent,
                  textColor: navy,
                  fontSize: 16.0);
            }
          }
        }
      });
    }
  }
  Future<void> Login() async {
    var bytes = utf8.encode(enteredPassword); // data being hashed
    var digest = sha256.convert(bytes);
    BluetoothDevice? device = connectedDevice;
    if (device != null) {
      // Discover all services and characteristics for the connected device
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) async {
        if (service.uuid.toString() == "25eb434a-260c-4df1-a39c-3b87e9c0ccfa") {
          for (BluetoothCharacteristic characteristic in service
              .characteristics) {
            // do something with characteristic
            if (characteristic.uuid.toString() ==
                "25eb434b-260c-4df1-a39c-3b87e9c0ccfa") {
              List <int> crypted_password = utf8.encode("LOG") + digest.bytes;
              await characteristic.write(crypted_password, withoutResponse: true);
              Fluttertoast.showToast(
                  msg: "Password is correct.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.redAccent,
                  textColor: navy,
                  fontSize: 16.0);
            }
          }
        }
      });
    }
  }

  Future<void> Lock() async {
    var bytes = utf8.encode(enteredPassword); // data being hashed
    var digest = sha256.convert(bytes);
    BluetoothDevice? device = connectedDevice;
    if (device != null) {
      // Discover all services and characteristics for the connected device
      List<BluetoothService> services = await device.discoverServices();
      services.forEach((service) async {
        if (service.uuid.toString() == "25eb434a-260c-4df1-a39c-3b87e9c0ccfa") {
          for (BluetoothCharacteristic characteristic in service
              .characteristics) {
            // do something with characteristic
            if (characteristic.uuid.toString() ==
                "25eb434b-260c-4df1-a39c-3b87e9c0ccfa") {
              List <int> crypted_password = utf8.encode("LCK") + digest.bytes;
              await characteristic.write(crypted_password, withoutResponse: true);
              Fluttertoast.showToast(
                  msg: "Locked.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.redAccent,
                  textColor: navy,
                  fontSize: 16.0);
            }
          }
        }
      });
    }
  }
  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: navy,
        ),
        centerTitle: true,
        title: Text(
          "BLE LOCKER",
          style: TextStyle(color: navy, fontSize: 25),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 25),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: navy),
                ),
                labelText: 'Password :',
                labelStyle: TextStyle(color: navy),
              ),
              style: TextStyle(color: navy),
              onChanged: (value) {
                setState(() {
                  enteredPassword = value ?? "";
                });
              },
            ),
            SizedBox(height: 5),

            SizedBox(
          width: 125, // Change this value to set the width of the button
          height: 75, // Change this value to set the height of the button
          child: FilledButton(
            onPressed: () {
              Login();
            },
            child: Text("SEND"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.redAccent),
              overlayColor: MaterialStateProperty.all(Colors.indigo),
            ),
          ),
        ),
        SizedBox(height: 25),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: navy),
            ),
            labelText: 'Set New Password :',
            labelStyle: TextStyle(color: navy),
          ),
          style: TextStyle(color: navy),
          onChanged: (value) {
            setState(() {
              newPassword = value ?? "";
            });
          },
        ),
            SizedBox(height: 5),

            SizedBox(
          width: 150, // Change this value to set the width of the button
          height: 75, // Change this value to set the height of the button
          child: FilledButton(
            onPressed: () {
              SetPassword();
            },
            child: Text("SET PASSWORD"),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.redAccent),
              overlayColor: MaterialStateProperty.all(Colors.indigo),
            ),
          ),
        ),

            SizedBox(height: 5),

            SizedBox(
              width: 150, // Change this value to set the width of the button
              height: 75, // Change this value to set the height of the button
              child: FilledButton(
                onPressed: () {
                 Lock();
                },
                child: Text("LOCK"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.redAccent),
                  overlayColor: MaterialStateProperty.all(Colors.indigo),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}