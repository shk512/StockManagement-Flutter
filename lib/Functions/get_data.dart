import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/company_model.dart';
import '../Models/user_model.dart';
import '../Services/DB/company_db.dart';
import '../Services/DB/user_db.dart';
import '../Services/shared_preferences/spf.dart';

Future getUserAndCompanyData(CompanyModel _companyModel,UserModel _userModel) async{
  await UserDb(id: FirebaseAuth.instance.currentUser!.uid).getData().then((value) async{
    await _userModel.fromJson(value).then((value) async{
      await CompanyDb(id: _userModel.userId).getData().then((value) async{
        await _companyModel.fromJson(value).then((value) async{
          await _companyModel.fromJson(value);
        });
      });
    });
  });
}