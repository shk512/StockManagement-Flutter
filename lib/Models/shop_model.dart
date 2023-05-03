import 'package:cloud_firestore/cloud_firestore.dart';

import 'geolocation_model.dart';

class ShopModel{
  static String shopId="";
  static String areaName="";
  static String shopName="";
  static String contact="";
  static String ownerName="";
  static String nearBy="";
  static bool isDeleted=false;

  static Map<String,dynamic> toJson({
    required String shopId,
    required String areaName,
    required String shopName,
    required String contact,
    required String ownerName,
    required bool isDeleted,
    required String nearBy,
    required var lat,
    required var lng
}){
    return {
      "shopId":shopId,
      "shopName":shopName,
      "areaId":areaName,
      "contact":contact,
      "nearBy":nearBy,
      "isDeleted":isDeleted,
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
    areaName=snapshot["areaId"];
    contact=snapshot["contact"];
    ownerName=snapshot["ownerName"];
    nearBy=snapshot["nearBy"];
    isDeleted=snapshot["isDeleted"];
    GeoLocationModel.lat=snapshot["geoLocation"]["lat"];
    GeoLocationModel.lng=snapshot["geoLocation"]["lng"];
  }

}