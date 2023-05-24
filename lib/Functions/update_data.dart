import 'package:flutter/material.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../Models/company_model.dart';
import '../Screens/Splash_Error/error.dart';
import '../Services/DB/company_db.dart';
import '../Services/DB/order_db.dart';

updateUserData(BuildContext context,UserModel _userModel) async{
  await UserDb(id: _userModel.userId).updateUser(_userModel.toJson()).then((value){
    showSnackbar(context, Colors.green.shade300, "Updated");
  }).onError((error, stackTrace) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error.toString(),key: Key("errorScreen"))));
  });
}

Future updateCompanyData(BuildContext context,CompanyModel _companyModel)async{
  await CompanyDb(id: _companyModel.companyId).updateCompany(_companyModel.toJson()).onError((error, stackTrace) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error.toString(),key: Key("errorScreen"))));
  });
}

Future updateOrderDetails(BuildContext context, Map<String, dynamic> mapData, String companyId, String orderId)async{
  await OrderDB(companyId: companyId, orderId: orderId).updateOrder(mapData).onError((error, stackTrace){
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error.toString(),key: Key("errorScreen"))));
  });
}

