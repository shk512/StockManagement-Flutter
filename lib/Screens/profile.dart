import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/user.dart';

import '../Models/company.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: Expanded(child: Text(UserModel.mail)),
        centerTitle: true,
        actions: [
          Icon(Icons.account_balance_wallet_outlined,color: Colors.white,),
          Padding(
              padding:EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              child: Text("Rs. ${UserModel.wallet}",style: TextStyle(fontSize: 17,color: Colors.white),textAlign: TextAlign.center,))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              displayFunction("Company Name", Company.companyName),
              const SizedBox(height: 10),
              displayFunction("Name", UserModel.name),
              const SizedBox(height: 10),
              displayFunction("Contact", UserModel.phone),
              const SizedBox(height: 10),
              displayFunction("Designation", UserModel.role),
              const SizedBox(height: 10),
              UserModel.salary!=""?displayFunction("Salary", UserModel.salary):SizedBox(),
              const SizedBox(height: 10),
              UserModel.role=="admin"?Container():Text("Area",style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
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
            flex: 2,
            child: Text(label,style: TextStyle(fontWeight: FontWeight.w900),)
        ),
        Expanded(
            flex: 3,
            child: Text(value)
        ),
      ],
    );
  }
}
