import 'dart:js_util';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_management/Models/geolocation_model.dart';

class OrderModel{
  String _orderId='';
  String _userId='';
  String _shopId='';
  String _status='';
  String _desc='';
  List _products=[];
  num _totalAmount=0;
  num _advanceAmount=0;
  num _concessionAmount=0;
  num _balanceAmount=0;
  GeoLocationModel _geoLocationModel=newObject();

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  GeoLocationModel get geoLocationModel => _geoLocationModel;

  set geoLocationModel(GeoLocationModel value) {
    _geoLocationModel = value;
  }

  String get shopId => _shopId;

  set shopId(String value) {
    _shopId = value;
  }

  String get orderId => _orderId;

  set orderId(String value) {
    _orderId = value;
  }

  String get userId => _userId;

  set userId(String value) {
    _userId = value;
  }

  num get advanceAmount => _advanceAmount;

  set advanceAmount(num value) {
    _advanceAmount = value;
  }

  num get balanceAmount => _balanceAmount;

  set balanceAmount(num value) {
    _balanceAmount = value;
  }

  num get concessionAmount => _concessionAmount;

  set concessionAmount(num value) {
    _concessionAmount = value;
  }

  num get totalAmount => _totalAmount;

  set totalAmount(num value) {
    _totalAmount = value;
  }

  List get products => _products;

  set products(List value) {
    _products = value;
  }

  String get desc => _desc;

  set desc(String value) {
    _desc = value;
  }

  Map<String,dynamic> toJson(){
    return{
      "orderId":orderId,
      "userId":userId,
      "shopId":shopId,
      "status":status,
      "products":products,
      "totalAmount":totalAmount,
      "advanceAmount":advanceAmount,
      "balanceAmount":balanceAmount,
      "concessionAmount":concessionAmount,
      "geoLocation":{
        "lat":geoLocationModel.lat,
        "lng":geoLocationModel.lng
      }
    };
  }
  void fromJson(DocumentSnapshot snapshot){
    orderId=snapshot["orderId"];
    userId=snapshot["userId"];
    shopId=snapshot["shopId"];
    status=snapshot["status"];
    products=snapshot["products"];
    totalAmount=snapshot["totalAmount"];
    advanceAmount=snapshot["advanceAmount"];
    balanceAmount=snapshot["balanceAmount"];
    concessionAmount=snapshot["concessionAmount"];
    geoLocationModel.lat=snapshot["geolocation"]["lat"];
    geoLocationModel.lng=snapshot["geolocation"]["lng"];
  }
}