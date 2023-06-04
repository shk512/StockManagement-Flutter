import 'package:flutter/material.dart';

import '../Models/account_model.dart';
import '../Screens/Splash_Error/error.dart';
import '../Services/DB/account_db.dart';

Future accountTransaction(String narration,num amount,String type,String desc,String companyId,String userId, BuildContext context) async{
  String transactionId=DateTime.now().microsecondsSinceEpoch.toString();
  AccountModel accountModel=AccountModel();
  accountModel.description=desc;
  accountModel.transactionBy=userId;
  accountModel.transactionId=transactionId;
  accountModel.narration=narration;
  accountModel.amount=amount;
  accountModel.type=type;
  accountModel.dateTime=DateTime.now().toString();
  await AccountDb(companyId: companyId, transactionId: transactionId).saveTransaction(accountModel.toJson()).onError((error, stackTrace) {
    Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"))));
  });
}
