import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Services/DB/user_db.dart';

import '../Models/company_model.dart';
import '../Models/geolocation_model.dart';
import '../Screens/Splash_Error/error.dart';
import '../Services/DB/company_db.dart';

updateUserData(BuildContext context) async{
  await UserDb(id: UserModel.userId).updateUser(UserModel.toJson(
      userId: UserModel.userId,
      companyId: UserModel.companyId,
      name: UserModel.name,
      mail: UserModel.mail,
      phone: UserModel.phone,
      role: UserModel.role,
      designation: UserModel.designation,
      wallet: UserModel.wallet,
      salary: UserModel.salary,
      isDeleted: UserModel.isDeleted,
      area: UserModel.area,
    right: UserModel.rights
  ));
}
updateCompanyData(BuildContext context)async {
  await CompanyDb(id: CompanyModel.companyId).updateCompany(CompanyModel.toJson(
      companyId: CompanyModel.companyId,
      companyName: CompanyModel.companyName,
      contact: CompanyModel.contact,
      packageEndsDate: CompanyModel.packageEndsDate,
      packageType: CompanyModel.packageType,
      whatsApp: CompanyModel.whatsApp,
      city: CompanyModel.city,
      wallet: CompanyModel.wallet,
      isPackageActive: CompanyModel.isPackageActive,
      area: CompanyModel.area,
      location: LatLng(CompanyModel.location.latitude, CompanyModel.location.longitude),
      imageUrl: CompanyModel.imageUrl
  )
  ).onError((error, stackTrace) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error.toString())));
  });
}