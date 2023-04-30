import 'dart:js_util';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'geolocation_model.dart';

class ShopModel{
  String _shopId="";
  String _areaId="";
  String _shopName="";
  String _contact="";
  String _ownerName="";
  GeoLocationModel _geoLocationModel=newObject();

  String get shopId => _shopId;

  set shopId(String value) {
    _shopId = value;
  }

  String get areaId => _areaId;

  set areaId(String value) {
    _areaId = value;
  }

  String get shopName => _shopName;

  set shopName(String value) {
    _shopName = value;
  }

  String get contact => _contact;

  set contact(String value) {
    _contact = value;
  }

  String get ownerName => _ownerName;

  set ownerName(String value) {
    _ownerName = value;
  }

  GeoLocationModel get geoLocationModel => _geoLocationModel;

  set geoLocationModel(GeoLocationModel value) {
    _geoLocationModel = value;
  }

  Map<String,dynamic> toJson(){
    return {
      "shopId":shopId,
      "shopName":shopName,
      "areaId":areaId,
      "contact":contact,
      "ownerName":ownerName,
      "geolocation": {
        "lat":geoLocationModel.lat,
        "lng":geoLocationModel.lng
      }
    };
  }

  void fromJson(DocumentSnapshot snapshot){
    shopName=snapshot["shopName"];
    shopId=snapshot["shopId"];
    areaId=snapshot["areaId"];
    contact=snapshot["contact"];
    ownerName=snapshot["ownerName"];
    geoLocationModel.lat=snapshot["geolocation"]["lat"];
    geoLocationModel.lng=snapshot["geolocation"]["lng"];
  }

}