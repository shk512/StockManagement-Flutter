import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'geolocation_model.dart';

class ShopModel{
  static String shopId="";
  static String areaName="";
  static String shopName="";
  static String contact="";
  static String ownerName="";
  static String nearBy="";
  static bool isDeleted=false;
  static GeoPoint location=const GeoPoint(0, 0);

  static Map<String,dynamic> toJson({
    required String shopId,
    required String areaName,
    required String shopName,
    required String contact,
    required String ownerName,
    required bool isDeleted,
    required String nearBy,
    required bool isActive,
    required LatLng location,
    required num wallet
}){
    return {
      "shopId":shopId,
      "shopName":shopName,
      "areaId":areaName,
      "contact":contact,
      "nearBy":nearBy,
      "isActive":isActive,
      "isDeleted":isDeleted,
      "ownerName":ownerName,
      "wallet":wallet,
      "geoLocation": GeoPoint(location.latitude, location.longitude)
    };
  }

  static fromJson(DocumentSnapshot snapshot){
    shopName=snapshot["shopName"];
    shopId=snapshot["shopId"];
    areaName=snapshot["areaId"];
    contact=snapshot["contact"];
    ownerName=snapshot["ownerName"];
    nearBy=snapshot["nearBy"];
    isDeleted=snapshot["isDeleted"];
    location=snapshot["geoLocation"];
  }

}