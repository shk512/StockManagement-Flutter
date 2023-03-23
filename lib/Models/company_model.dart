import 'package:cloud_firestore/cloud_firestore.dart';

class Company{
  static String companyId="";
  static String companyName="";
  static String contact="";
  static String packageEndsDate="";
  static bool isPackageActive=false;
  static List area=[];

  static fromJson(DocumentSnapshot mapData){
    companyId=mapData['companyId'];
    contact=mapData['contact'];
    isPackageActive= mapData['isPackageActive'];
    packageEndsDate= mapData['packageEndsDate'];
    companyName= mapData['companyName'];
    area=mapData['area'];
  }
}