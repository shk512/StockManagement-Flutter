import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderModel{
  static List products=[];
  static num totalAmount=0;

  static Map<String,dynamic> toJson({
    required String  orderId,
    required String userId,
    required String deliverId,
    required String shopId,
    required String shopDetails,
    required String status,
    required String remarks,
    required String desc,
    required String dateTime,
    required List products,
    required num totalAmount,
    required num advanceAmount,
    required num concessionAmount,
    required num balanceAmount,
    required LatLng location
  }){
    return{
      "orderId":orderId,
      "orderBy":userId,
      "deliverBy":deliverId,
      "shopId":shopId,
      "shopDetails":shopDetails,
      "status":status,
      "remarks":remarks,
      "description":desc,
      "dateTime":dateTime,
      "products":products,
      "totalAmount":totalAmount,
      "advanceAmount":advanceAmount,
      "balanceAmount":balanceAmount,
      "concessionAmount":concessionAmount,
      "geoLocation":GeoPoint(location.latitude, location.longitude)
    };
  }
}