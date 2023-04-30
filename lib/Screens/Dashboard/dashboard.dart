import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Services/DB/company_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/Widgets/dashboard_menu.dart';
import 'package:stock_management/utils/routes.dart';

import '../../Functions/sign_out.dart';

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
    CompanyModel.fromJson(snapshot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pushNamed(context, Routes.profile);
          },
          child: const Icon(CupertinoIcons.person_crop_circle,color: Colors.white,),
        ),
        title: Text(CompanyModel.companyName,style: const TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: (){
              signOut(context);
            },
            child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.logout_outlined,color: Colors.white,)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: Column(
            children: [
              DashboardMenu(name: "Order", route: Routes.order, icon: Icons.shopping_cart, clr: Colors.red.withOpacity(300)),
              const SizedBox(height: 10,),
              DashboardMenu(name: "Stock", route: Routes.stock, icon: Icons.cached_outlined, clr: Colors.green.withOpacity(300)),
              const SizedBox(height: 10,),
              DashboardMenu(name: "User", route: Routes.employee, icon: Icons.person, clr: Colors.green),
              const SizedBox(height: 10,),
              DashboardMenu(name: "Product", route: Routes.product, icon: Icons.add_box, clr: Colors.green.withOpacity(300)),
              const SizedBox(height: 10,),
              DashboardMenu(name: "Area/Shops", route: Routes.area, icon: Icons.storefront, clr: Colors.purpleAccent),
              const SizedBox(height: 10,),
              DashboardMenu(name: "Accounts", route: Routes.accounts, icon: Icons.account_balance_sharp, clr: Colors.grey),
            ],
          ),
        )
      ),
    );
  }
}
