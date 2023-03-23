import 'package:cloud_firestore/cloud_firestore.dart';

class AreaModel{
  static String areaId="";
  static String companyId="";
  static String userId="";
  static String areaName="";

  AreaModel(String company,String area,String user,String name){
    companyId=company;
    areaId=area;
    userId=user;
    areaName=name;
  }
   Map<String,dynamic> toJson(){
    return {
      "companyId":companyId,
      "areaId":areaId,
      "areaName":areaName,
      "userId":userId,
    };
   }
   static fromJson(DocumentSnapshot snapshot){
    companyId=snapshot["companyId"];
    userId=snapshot["userId"];
    areaName=snapshot["areaName"];
    areaId=snapshot["areaId"];
   }
}