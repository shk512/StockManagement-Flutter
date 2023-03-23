import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel{
  static String orderId="";
  static String companyId="";
  static String userId="";
  static String orderDetails="";
  static num totalAmount=0;
  static num concessionAmount=0;
  static num balanceAmount=0;
  static num amountReceived=0;

  OrderModel(String orderId1, String companyId1, String orderTakerId1, String orderDetails1, num total, num balance, num concession, num receive){
    orderId=orderId1;
    companyId=companyId1;
    userId=orderTakerId1;
    orderDetails=orderDetails1;
    totalAmount=total;
    balanceAmount=balance;
    concessionAmount=concession;
    amountReceived=receive;
  }
  Map<String,dynamic> toJson(){
    return{
      "orderId":orderId,
      "companyId":companyId,
      "userId":userId,
      "orderDetails":orderDetails,
      "totalAmount":totalAmount,
      "balanceAmount":balanceAmount,
      "concessionAmount":concessionAmount,
      "receiveAmount":amountReceived
    };
  }
  static fromJson(DocumentSnapshot snapshot){
    orderId=snapshot["orderId"];
    companyId=snapshot["companyId"];
    userId=snapshot["userId"];
    orderDetails=snapshot["orderDetails"];
    totalAmount=snapshot["totalAmount"];
    amountReceived=snapshot["receiveAmount"];
    balanceAmount=snapshot["balanceAmount"];
    concessionAmount=snapshot["concessionAmount"];
  }
}