import 'package:flutter/material.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../Models/company_model.dart';
import '../Screens/Splash_Error/error.dart';
import '../Services/DB/company_db.dart';
import '../Services/DB/order_db.dart';

updateUserData(BuildContext context,UserModel _userModel) async{
  await UserDb(id: _userModel.userId).updateUser(_userModel.toJson(
      userId: _userModel.userId,
      name: _userModel.name,
      salary: _userModel.salary,
      mail: _userModel.mail,
      companyId: _userModel.companyId,
      phone: _userModel.phone,
      role: _userModel.role,
      designation: _userModel.designation,
      wallet: _userModel.wallet,
      isDeleted: _userModel.isDeleted,
      rights: _userModel.rights,
      area: _userModel.area)).then((value){
    showSnackbar(context, Colors.cyan, "Updated");
  }).onError((error, stackTrace) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error.toString())));
  });
}

Future updateCompanyData(BuildContext context,CompanyModel _companyModel)async{
  await CompanyDb(id: _companyModel.companyId).updateCompany(_companyModel.toJson()).onError((error, stackTrace) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error.toString())));
  });
}

Future updateOrderDetails(BuildContext context, Map<String, dynamic> mapData, String companyId, String orderId)async{
  await OrderDB(companyId: companyId, orderId: orderId).updateOrder(mapData).onError((error, stackTrace){
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error.toString())));
  });
}

