import 'dart:js_util';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'geolocation_model.dart';

class ShopModel{
  static String shopId="";
  static String areaId="";
  static String shopName="";
  static String contact="";
  static String ownerName="";

  static Map<String,dynamic> toJson({
    required String shopId,
    required String areaId,
    required String shopName,
    required String contact,
    required String ownerName,
    required var lat,
    required var lng
}){
    return {
      "shopId":shopId,
      "shopName":shopName,
      "areaId":areaId,
      "contact":contact,
      "ownerName":ownerName,
      "geoLocation": {
        "lat":lat,
        "lng":lng
      }
    };
  }

  static fromJson(DocumentSnapshot snapshot){
    shopName=snapshot["shopName"];
    shopId=snapshot["shopId"];
    areaId=snapshot["areaId"];
    contact=snapshot["contact"];
    ownerName=snapshot["ownerName"];
    GeoLocationModel.lat=snapshot["geoLocation"]["lat"];
    GeoLocationModel.lng=snapshot["geoLocation"]["lng"];
  }

}