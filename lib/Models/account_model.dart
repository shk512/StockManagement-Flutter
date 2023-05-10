import 'package:cloud_firestore/cloud_firestore.dart';

class AccountModel{

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

}