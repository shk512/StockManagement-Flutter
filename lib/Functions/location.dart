import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';

Future<String> convertCoordiantesToAddress(var lat, var lng)async{
  List<Placemark> placemark=await placemarkFromCoordinates(lat, lng);
  return "${placemark.reversed.last.locality}, ${placemark.reversed.last.subLocality}";
}
Future<Position> getCurrentLocation(BuildContext context)async{
  await Geolocator.requestPermission().then((value) {

  }).onError((error, stackTrace) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
  });
  return await Geolocator.getCurrentPosition();
}