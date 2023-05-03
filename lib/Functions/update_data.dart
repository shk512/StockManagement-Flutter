import 'package:flutter/material.dart';

import '../Models/company_model.dart';
import '../Models/geolocation_model.dart';
import '../Screens/Splash_Error/error.dart';
import '../Services/DB/company_db.dart';

updateUserData(BuildContext context) async{
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
      lat: GeoLocationModel.lat,
      lng: GeoLocationModel.lng
  )
  ).onError((error, stackTrace) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error.toString())));
  });
}