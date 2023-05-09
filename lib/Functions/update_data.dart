import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../Models/company_model.dart';
import '../Models/geolocation_model.dart';
import '../Screens/Splash_Error/error.dart';
import '../Services/DB/company_db.dart';

updateUserData(BuildContext context,UserModel _userModel) async{
  await UserDb(id: _userModel.userId).updateUser(_userModel.toJson()).then((value){
    showSnackbar(context, Colors.cyan, "Updated");
  }).onError((error, stackTrace) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error.toString())));
  });
}
updateCompanyData(BuildContext context,CompanyModel _companyModel)async {
  await CompanyDb(id: _companyModel.companyId).updateCompany(_companyModel.toJson()).then((value){
    showSnackbar(context, Colors.cyan, "Updated");
  }).onError((error, stackTrace) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error.toString())));
  });
}