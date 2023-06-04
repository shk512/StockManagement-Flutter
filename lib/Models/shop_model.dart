import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel{
  String _shopId="";
  String _areaId="";
  String _shopName="";
  String _contact="";
  String _ownerName="";
  String _nearBy="";
  bool _isDeleted=false;
  bool _isActive=false;
  GeoPoint _location=GeoPoint(0, 0);
  num _wallet=0;

  Map<String,dynamic> toJson(){
    return {
      "shopId":shopId,
      "shopName":shopName,
      "areaId":areaId,
      "contact":contact,
      "nearBy":nearBy,
      "isActive":isActive,
      "isDeleted":isDeleted,
      "ownerName":ownerName,
      "wallet":wallet,
      "geoLocation": GeoPoint(location.latitude, location.longitude)
    };
  }

  fromJson(DocumentSnapshot snapshot){
    shopId=snapshot["shopId"];
    shopName=snapshot["shopName"];
    areaId=snapshot["areaId"];
    contact=snapshot["contact"];
    nearBy=snapshot["nearBy"];
    isActive=snapshot["isActive"];
    isDeleted=snapshot["isDeleted"];
    ownerName=snapshot["ownerName"];
    wallet=snapshot["wallet"];
    location=snapshot["geoLocation"];
  }


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

  String get nearBy => _nearBy;

  set nearBy(String value) {
    _nearBy = value;
  }

  bool get isDeleted => _isDeleted;

  set isDeleted(bool value) {
    _isDeleted = value;
  }

  bool get isActive => _isActive;

  set isActive(bool value) {
    _isActive = value;
  }

  GeoPoint get location => _location;

  set location(GeoPoint value) {
    _location = value;
  }

  num get wallet => _wallet;

  set wallet(num value) {
    _wallet = value;
  }
}