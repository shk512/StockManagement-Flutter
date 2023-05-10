import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel{
  static String transactionId='';
  static String desc='';
  static num amount=0;
  static String type='';
  static String dateTime='';

  static Map<String,dynamic> toJson({
    required String transactionId,
    required String transactionBy,
    required String desc,
    required String narration,
    required num amount,
    required String type,
    required String dateTime
}){
    return{
      "transactionId":transactionId,
      "type":type,
      "transactionBy":transactionBy,
      "narration":narration,
      "description":desc,
      "amount":amount,
      "date":dateTime
    };
  }

  static fromJson(DocumentSnapshot snapshot){
    transactionId=snapshot["transactionId"];
    type=snapshot["type"];
    desc=snapshot["description"];
    amount=snapshot["amount"];
    dateTime=snapshot["date"];
  }
}