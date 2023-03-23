import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel{
  static String shopId="";
  static String areaId="";
  static String shopName="";
  static String contact="";
  static String ownerName="";

  ShopModel(String shopId1,String areaId1,String shopName1,String contact1,String ownerName1){
    shopId=shopId1;
    shopName=shopName1;
    areaId=areaId1;
    contact=contact1;
    ownerName=ownerName1;
  }

  Map<String,dynamic> toJson(){
    return {
      "shopId":shopId,
      "shopName":shopName,
      "areaId":areaId,
      "contact":contact,
      "ownerName":ownerName
    };
  }

  static fromJson(DocumentSnapshot snapshot){
    shopName=snapshot["shopName"];
    shopId=snapshot["shopId"];
    areaId=snapshot["areaId"];
    contact=snapshot["contact"];
    ownerName=snapshot["ownerName"];
  }
}