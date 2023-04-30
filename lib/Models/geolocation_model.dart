import 'package:cloud_firestore/cloud_firestore.dart';

class GeoLocationModel{
  var _lat;

  get lat => _lat;

  set lat(value) {
    _lat = value;
  }

  var _lng;

  get lng => _lng;

  set lng(value) {
    _lng = value;
  }

   Map<String,dynamic> toJson(){
    return {
      "lat":lat,
      "lng":lng
    };
   }
   void fromJson(DocumentSnapshot snapshot){
    lat=snapshot["lat"];
    lng=snapshot["lng"];
   }
}