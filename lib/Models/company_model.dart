import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyModel{
  String _imageUrl='';
  String _companyId="";
  String _contact="";
  String _companyName="";
  String _packageEndsDate="";
  String _packageType="";
  String _whatsApp="";
  String _city="";
  num _wallet=0;
  bool _isPackageActive=false;
  List _area=[];
  GeoPoint _location=GeoPoint(0, 0);

  Map<String,dynamic> toJson()
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

  String get imageUrl => _imageUrl;

  set imageUrl(String value) {
    _imageUrl = value;
  }

  String get companyId => _companyId;

  set companyId(String value) {
    _companyId = value;
  }

  String get contact => _contact;

  set contact(String value) {
    _contact = value;
  }

  String get companyName => _companyName;

  set companyName(String value) {
    _companyName = value;
  }

  String get packageEndsDate => _packageEndsDate;

  set packageEndsDate(String value) {
    _packageEndsDate = value;
  }

  String get packageType => _packageType;

  set packageType(String value) {
    _packageType = value;
  }

  String get whatsApp => _whatsApp;

  set whatsApp(String value) {
    _whatsApp = value;
  }

  String get city => _city;

  set city(String value) {
    _city = value;
  }

  num get wallet => _wallet;

  set wallet(num value) {
    _wallet = value;
  }

  bool get isPackageActive => _isPackageActive;

  set isPackageActive(bool value) {
    _isPackageActive = value;
  }

  List get area => _area;

  set area(List value) {
    _area = value;
  }

  GeoPoint get location => _location;

  set location(GeoPoint value) {
    _location = value;
  }
}