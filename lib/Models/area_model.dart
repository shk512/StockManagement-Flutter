import 'package:cloud_firestore/cloud_firestore.dart';

class AreaModel{
  String _areaId="";
  String _areaName="";
  bool _isDeleted=false;

  Map<String, dynamic> toJson(){
    return {
      "areaId": areaId,
      "areaName": areaName,
      "isDeleted": isDeleted
    };
  }

  fromJson(DocumentSnapshot snapshot){
    areaId=snapshot["areaId"];
    areaName=snapshot["areaName"];
    isDeleted=snapshot["isDeleted"];
  }

  String get areaId => _areaId;

  set areaId(String value) {
    _areaId = value;
  }

  String get areaName => _areaName;

  set areaName(String value) {
    _areaName = value;
  }

  bool get isDeleted => _isDeleted;

  set isDeleted(bool value) {
    _isDeleted = value;
  }
}