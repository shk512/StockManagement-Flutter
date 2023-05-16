
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:maps_launcher/maps_launcher.dart';

Future<void> openMap(var lat, var lng)async{
  if(defaultTargetPlatform==TargetPlatform.android||defaultTargetPlatform==TargetPlatform.iOS){
    MapsLauncher.launchCoordinates(lat, lng);
  }else{
    String googleUrl="https://maps.google.com/maps/search/?api=1&query=$lat,$lng";
    if (await canLaunchUrlString(googleUrl)) {
      await launchUrlString(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}