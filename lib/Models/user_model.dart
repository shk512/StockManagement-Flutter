import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  static String userId='';
  static String companyId='';
  static String name='';
  static String mail='';
  static String phone='';
  static String role='';
  static num wallet=0;
  static num salary=0;
  static List area=[];
  static List rights=[];
  static bool isDeleted=false;

  static Map<String,dynamic> toJson({
    required String userId,
    required String companyId,
    required String name,
    required String mail,
    required String phone,
    required String role,
    required num wallet,
    required num salary,
    required bool isDeleted,
    required List area,
    required List right
}){
    return {
      "userId":userId,
      "name":name,
      "salary":salary,
      "mail":mail,
      "companyId":companyId,
      "phone":phone,
      "role":role,
      "wallet":wallet,
      "isDeleted":isDeleted,
      "right":right,
      "area":area
    };
  }

  static fromJson(DocumentSnapshot snapshot){
    userId=snapshot["userId"];
    companyId=snapshot["companyId"];
    name=snapshot["name"];
    salary=snapshot["salary"];
    mail=snapshot["mail"];
    phone=snapshot["phone"];
    wallet=snapshot["wallet"];
    role=snapshot["role"];
    isDeleted=snapshot["isDeleted"];
    area=List.from(snapshot["area"]);
    rights=List.from(snapshot["right"]);
  }
}