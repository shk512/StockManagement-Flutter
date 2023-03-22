import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  static String mail="";
  static String phone="";
  static String role="";
  static String wallet="";
  static String companyId="";
  static String salary="";
  static String name="";

  User(String companyId1,String mail1,String phone1,String role1,String salary1,String name1){
    mail=mail1;
    name=name1;
    phone=phone1;
    role=role1;
    salary=salary1;
    companyId=companyId1;
  }

  Map<String,dynamic> toJson(){
    return {
      "name":name,
      "salary":salary,
      "mail":mail,
      "companyId":companyId,
      "phone":phone,
      "role":role,
      "wallet":wallet,
  };
}

  static fromJson(DocumentSnapshot snapshot){
    companyId=snapshot["companyId"];
    mail=snapshot["mail"];
    phone=snapshot["phone"];
    role=snapshot["role"];
    name=snapshot["name"];
    salary=snapshot["salary"];
    wallet=snapshot["wallet"];
  }
}