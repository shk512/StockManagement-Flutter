import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel{
  String _transactionId='';
  String _desc='';
  num _amount=0;
  String _type='';

  String get transactionId => _transactionId;

  set transactionId(String value) {
    _transactionId = value;
  }

  String get desc => _desc;

  set desc(String value) {
    _desc = value;
  }

  String get type => _type;

  set type(String value) {
    _type = value;
  }

  num get amount => _amount;

  set amount(num value) {
    _amount = value;
  }

  Map<String,dynamic> toJson(){
    return{
      "transactionId":transactionId,
      "type":type,
      "description":desc,
      "amount":amount
    };
  }

  void fromJson(DocumentSnapshot snapshot){
    transactionId=snapshot["transactionId"];
    type=snapshot["type"];
    desc=snapshot["description"];
    amount=snapshot["amount"];
  }
}