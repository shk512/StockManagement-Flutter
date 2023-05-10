import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class ShopModel{

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

}