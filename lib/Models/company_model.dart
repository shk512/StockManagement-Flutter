
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_management/Models/geolocation_model.dart';

class CompanyModel{
  static String companyId='';
  static String companyName='';
  static String contact='';
  static String packageEndsDate='';
  static String packageType='';
  static String whatsApp='';
  static String city='';
  static num wallet=0;
  static bool isPackageActive=false;
  static List area=[];

  static Map<String,dynamic> toJson({
  required String companyId,
  required String companyName,
  required String contact,
  required String packageEndsDate,
  required String packageType,
  required String whatsApp,
  required String city,
  required num wallet,
  required bool isPackageActive,
  required List area,
})
    {
      return{
        "companyId": companyId,
        "companyName":companyName,
        "isPackageActive":isPackageActive,
        "contact":contact,
        "packageEndsDate":packageEndsDate,
        "area":area,
        "wallet":wallet,
        "whatsApp":whatsApp,
        "packageType":packageType,
        "city":city,
        "geoLocation":{
          "lat":GeoLocationModel.lat,
          "lng":GeoLocationModel.lng
        }
     };
    }

  static fromJson(DocumentSnapshot snapshot){
    companyId=snapshot['companyId'];
    contact=snapshot['contact'];
    isPackageActive= snapshot['isPackageActive'];
    packageEndsDate= snapshot['packageEndsDate'];
    companyName= snapshot['companyName'];
    area=snapshot['area'];
    wallet=snapshot['wallet'];
    packageType=snapshot["packageType"];
    whatsApp=snapshot["whatsApp"];
    city=snapshot["city"];
    GeoLocationModel.lat=snapshot["geoLocation"]["lat"];
    GeoLocationModel.lng=snapshot["geoLocation"]["lng"];
  }

}