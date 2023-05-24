import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';

Future<Position> getCurrentLocation(BuildContext context)async{
  await Geolocator.requestPermission().then((value) {

  }).onError((error, stackTrace) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"))));
  });
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}