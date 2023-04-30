import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel{
  String _companyId='';
  String _companyName='';
  String _contact='';
  String _packageEndsDate='';
  num _wallet=0;
  bool _isPackageActive=false;
  List _area=[];

  num get wallet => _wallet;

  set wallet(num value) {
    _wallet = value;
  }

  String get companyId => _companyId;

  set companyId(String value) {
    _companyId = value;
  }

  String get companyName => _companyName;

  set companyName(String value) {
    _companyName = value;
  }

  String get contact => _contact;

  set contact(String value) {
    _contact = value;
  }

  String get packageEndsDate => _packageEndsDate;

  set packageEndsDate(String value) {
    _packageEndsDate = value;
  }

  bool get isPackageActive => _isPackageActive;

  set isPackageActive(bool value) {
    _isPackageActive = value;
  }

  List get area => _area;

  set area(List value) {
    _area = value;
  }

  Map<String,dynamic> toJson()
    {
      return{
        "companyId": companyId,
        "companyName":companyName,
        "isPackageActive":isPackageActive,
        "contact":contact,
        "packageEndsDate":packageEndsDate,
        "area":area,
        "wallet":wallet
     };
    }

  void fromJson(DocumentSnapshot snapshot){
    companyId=snapshot['companyId'];
    contact=snapshot['contact'];
    isPackageActive= snapshot['isPackageActive'];
    packageEndsDate= snapshot['packageEndsDate'];
    companyName= snapshot['companyName'];
    area=snapshot['area'];
    wallet=snapshot['wallet'];
  }
}