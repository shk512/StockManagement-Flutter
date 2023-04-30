import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  String _userId='';
  String _companyId='';
  String _name='';
  String _mail='';
  String _phone='';
  String _role='';
  num _wallet=0;
  num _salary=0;


  String get mail => _mail;

  set mail(String value) {
    _mail = value;
  }

  String get phone => _phone;

  set phone(String value) {
    _phone = value;
  }

  String get role => _role;

  set role(String value) {
    _role = value;
  }

  num get wallet => _wallet;

  set wallet(num value) {
    _wallet = value;
  }

  String get companyId => _companyId;

  set companyId(String value) {
    _companyId = value;
  }

  String get userId => _userId;

  set userId(String value) {
    _userId = value;
  }

  num get salary => _salary;

  set salary(num value) {
    _salary = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  Map<String,dynamic> toJson(){
    return {
      "userId":userId,
      "name":name,
      "salary":salary,
      "mail":mail,
      "companyId":companyId,
      "phone":phone,
      "role":role,
      "wallet":wallet,
    };
  }

  void fromJson(DocumentSnapshot snapshot){
    userId=snapshot["userId"];
    companyId=snapshot["companyId"];
    name=snapshot["name"];
    salary=snapshot["salary"];
    mail=snapshot["mail"];
    phone=snapshot["phone"];
    wallet=snapshot["wallet"];
    role=snapshot["_role"];
  }
}