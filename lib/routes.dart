import 'package:ble_locker/Screens/Connection.dart';
import 'package:flutter/material.dart';
import 'package:ble_locker/Screens/Home.dart';
import 'package:ble_locker/Screens/SplashScreen.dart';



Map<String, WidgetBuilder> routes = {

  Home.routeName : (context)=> Home(),
  Connection.routeName : (context) => Connection(),


};