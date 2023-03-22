import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company.dart';
import 'package:stock_management/Models/user.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Services/DB/company_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/utils/routes.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  Auth auth=Auth();

  @override
  void initState() {
    super.initState();
    getData();
  }
  getData()async{
    DocumentSnapshot snapshot=await UserDb(id: FirebaseAuth.instance.currentUser!.uid).getData();
    UserModel.fromJson(snapshot);
    snapshot=await CompanyDb(id: UserModel.companyId).getData();
    Company.fromJson(snapshot);
  }

  @override
  Widget build(BuildContext context) {
    return Company.companyName==""?
    const Center(child: CircularProgressIndicator(),)
    :Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pushNamed(context, Routes.profile);
          },
          child: const Icon(CupertinoIcons.person_crop_circle,color: Colors.white,),
        ),
        title: Text(Company.companyName,style: const TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: (){
              signOut();
            },
            child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.logout_outlined,color: Colors.white,)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [],
        )
      ),
    );
  }
  signOut()async{
    await auth.firebaseAuth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }
}
