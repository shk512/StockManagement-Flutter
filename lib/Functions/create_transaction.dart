import 'package:flutter/material.dart';

import '../Models/account_model.dart';
import '../Screens/Splash_Error/error.dart';
import '../Services/DB/account_db.dart';

Future accountTransaction(String narration,num amount,String type,String desc,String companyId,String userId, BuildContext context) async{
  String transactionId=DateTime.now().microsecondsSinceEpoch.toString();
  await AccountDb(companyId: companyId, transactionId: transactionId).saveTransaction(
      AccountModel.toJson(
          transactionId: transactionId,
          transactionBy: userId,
          desc: desc,
          narration: narration,
          amount: amount,
          type: type,
          dateTime: DateTime.now().toString()
      )).onError((error, stackTrace) {
    Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
  });
}
