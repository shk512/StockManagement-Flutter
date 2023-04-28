import 'package:cloud_firestore/cloud_firestore.dart';

class AreaModel{
  static String areaId="";
  static String companyId="";
  static String orderTakerId="";
  static String areaName="";
  static String supplierId="";

  AreaModel(String company,String area,String user,String supplier,String name){
    companyId=company;
    areaId=area;
    orderTakerId=user;
    supplierId=supplier;
    areaName=name;
  }
   Map<String,dynamic> toJson(){
    return {
      "companyId":companyId,
      "areaId":areaId,
      "areaName":areaName,
      "orderTakerId":orderTakerId,
      "supplierId":supplierId
    };
   }
   static fromJson(DocumentSnapshot snapshot){
    companyId=snapshot["companyId"];
    orderTakerId=snapshot["userId"];
    supplierId=snapshot["supplierId"];
    areaName=snapshot["areaName"];
    areaId=snapshot["areaId"];
   }
}