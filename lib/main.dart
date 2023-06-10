import 'package:ble_locker/Screens/Connection.dart';
import 'package:flutter/material.dart';
import 'Screens/Home.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Connection.routeName,
      routes: {
        Home.routeName: (context) => Home(),
        Connection.routeName: (context) => Connection(),
      },
    );
  }
}