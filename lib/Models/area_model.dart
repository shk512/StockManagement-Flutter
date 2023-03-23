import 'package:cloud_firestore/cloud_firestore.dart';

class AreaModel{
  static String areaId="";
  static String userId="";
  static String areaName="";

  AreaModel(String area,String user,String name){
    areaId=area;
    userId=user;
    areaName=name;
  }
   Map<String,dynamic> toJson(){
    return {
      "areaId":areaId,
      "areaName":areaName,
      "userId":userId,
    };
   }
   static fromJson(DocumentSnapshot snapshot){
    userId=snapshot["userId"];
    areaName=snapshot["areaName"];
    areaId=snapshot["areaId"];
   }
}