
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel{

  String _transactionId="";
  String _transactionBy="";
  String _description="";
  String _narration="";
  String _type="";
  String _dateTime="";
  num _amount=0;

  Map<String,dynamic> toJson(){
    return{
      "transactionId":transactionId,
      "type":type,
      "transactionBy":transactionBy,
      "narration":narration,
      "description":description,
      "amount":amount,
      "date":dateTime
    };
  }

  fromJson(DocumentSnapshot snapshot){
    transactionId=snapshot["transactionId"];
    transactionBy=snapshot["transactionBy"];
    type=snapshot["type"];
    narration=snapshot["narration"];
    description=snapshot["description"];
    dateTime=snapshot["date"];
    amount=snapshot["amount"];
  }

  String get transactionId => _transactionId;

  set transactionId(String value) {
    _transactionId = value;
  }

  String get transactionBy => _transactionBy;

  set transactionBy(String value) {
    _transactionBy = value;
  }

  num get amount => _amount;

  set amount(num value) {
    _amount = value;
  }

  String get dateTime => _dateTime;

  set dateTime(String value) {
    _dateTime = value;
  }

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  String get narration => _narration;

  set narration(String value) {
    _narration = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }
}