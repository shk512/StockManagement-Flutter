import 'package:flutter/material.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Services/shared_preferences/spf.dart';

import '../Constants/routes.dart';
import '../utils/snack_bar.dart';

signOut(BuildContext context)async{
  Auth auth=Auth();
  await SPF.saveUserLogInStatus(false);
  await auth.signOut().then((value){
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }).onError((error, stackTrace) {
    showSnackbar(context, Colors.red, error.toString());
  });

}