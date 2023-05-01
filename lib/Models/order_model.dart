import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_management/Models/geolocation_model.dart';

class OrderModel{
  static String  orderId='';
  static String userId='';
  static String shopId='';
  static String status='';
  static String description='';
  static String dateTime='';
  static List products=[];
  static num totalAmount=0;
  static num advanceAmount=0;
  static num concessionAmount=0;
  static num balanceAmount=0;

  static Map<String,dynamic> toJson({
    required String  orderId,
    required String userId,
    required String shopId,
    required String status,
    required String desc,
    required String dateTime,
    required List products,
    required num totalAmount,
    required num advanceAmount,
    required num concessionAmount,
    required num balanceAmount,
    required var lat,
    required var lng
  }){
    return{
      "orderId":orderId,
      "userId":userId,
      "shopId":shopId,
      "status":status,
      "description":desc,
      "dateTime":dateTime,
      "products":products,
      "totalAmount":totalAmount,
      "advanceAmount":advanceAmount,
      "balanceAmount":balanceAmount,
      "concessionAmount":concessionAmount,
      "geoLocation":{
        "lat":lat,
        "lng":lng
      }
    };
  }
  void fromJson(DocumentSnapshot snapshot){
    orderId=snapshot["orderId"];
    userId=snapshot["userId"];
    shopId=snapshot["shopId"];
    status=snapshot["status"];
    products=snapshot["products"];
    description=snapshot["description"];
    dateTime=snapshot["dateTime"];
    totalAmount=snapshot["totalAmount"];
    advanceAmount=snapshot["advanceAmount"];
    balanceAmount=snapshot["balanceAmount"];
    concessionAmount=snapshot["concessionAmount"];
    GeoLocationModel.lat=snapshot["geoLocation"]["lat"];
    GeoLocationModel.lng=snapshot["geoLocation"]["lng"];
  }
}