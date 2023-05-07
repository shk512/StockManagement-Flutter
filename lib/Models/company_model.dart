import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CompanyModel{
  static String imageUrl="";
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
  static GeoPoint location=const GeoPoint(0, 0);

  static fromJson(DocumentSnapshot snapshot){
    imageUrl=snapshot["imageUrl"];
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
    location=snapshot["geoLocation"];
  }

  static Map<String,dynamic> toJson({
    required String companyId,
    required String companyName,
    required String contact,
    required String whatsApp,
    required String packageEndsDate,
    required String packageType,
    required String city,
    required num wallet,
    required List area,
    required bool isPackageActive,
    required LatLng location,
    required String imageUrl
  })
  {
    return<String,dynamic>{
      "imageUrl":imageUrl,
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
      "geoLocation":GeoPoint(location.latitude,location.longitude)
    };
  }
}