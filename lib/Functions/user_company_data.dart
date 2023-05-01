import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/company_model.dart';
import '../Models/user_model.dart';
import '../Services/DB/company_db.dart';
import '../Services/DB/user_db.dart';

Future getUserAndCompanyData(String userId) async{
  DocumentSnapshot snapshot=await UserDb(id: userId).getData();
  await UserModel.fromJson(snapshot);
  snapshot=await CompanyDb(id: UserModel.companyId).getData();
  await CompanyModel.fromJson(snapshot);
}