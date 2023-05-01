import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/user_company_data.dart';
import 'package:stock_management/Models/user_model.dart';

import '../../Models/company_model.dart';


class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: const Text("Profile",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          const Icon(Icons.account_balance_wallet_outlined,color: Colors.white,),
          Padding(
              padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              child: Text(
                "Rs. ${UserModel.wallet}",
                style: const TextStyle(fontSize: 17,color: Colors.white),textAlign: TextAlign.center,),),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              displayFunction("Email", UserModel.mail.toLowerCase()),
              const SizedBox(height: 10),
              displayFunction("Company", CompanyModel.companyName.toUpperCase()),
              const SizedBox(height: 10),
              displayFunction("Name", UserModel.name.toUpperCase()),
              const SizedBox(height: 10),
              displayFunction("Contact", UserModel.phone),
              const SizedBox(height: 10),
              displayFunction("Designation", UserModel.role.toUpperCase()),
              const SizedBox(height: 10),
              UserModel.salary!=0?displayFunction("Salary", UserModel.salary.toString()):const SizedBox(),
              const SizedBox(height: 10),
              UserModel.role=="shop keeper".toUpperCase()?Container():const Text("Area Assigned",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
            ],
        ),
        ),
      ),
    );
  }
  Widget displayFunction(String label,String value){
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Text(label,style: const TextStyle(fontWeight: FontWeight.w900),)
        ),
        Expanded(
            flex: 3,
            child: Text(value)
        ),
      ],
    );
  }
}
