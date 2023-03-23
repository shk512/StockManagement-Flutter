import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
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
    return Scaffold(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: Column(
            children: [
              displayFunction(Colors.amberAccent,"Order",Icons.shopping_cart, Routes.order),
              const SizedBox(height: 10,),
              displayFunction(Colors.lightGreen,"Stock",Icons.cached_outlined, Routes.stock),
              const SizedBox(height: 10,),
              displayFunction(Colors.orangeAccent, "User", Icons.person, Routes.epmloyee),
              const SizedBox(height: 10,),
              displayFunction(Colors.pinkAccent, "Product", Icons.add_box, Routes.product),
              const SizedBox(height: 10,),
              displayFunction(Colors.lime, "Shop", Icons.storefront, Routes.shop),
              const SizedBox(height: 10,),
              displayFunction(Colors.teal, "Area", Icons.pin_drop, Routes.shop),
              const SizedBox(height: 10,),
              displayFunction(Colors.blueGrey, "Accounts", Icons.account_balance_sharp, Routes.accounts),
            ],
          ),
        )
      ),
    );
  }
  signOut()async{
    await auth.firebaseAuth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }

  Widget displayFunction(Color clr, String name, IconData icon,String route){
    return InkWell(
      onTap: (){
        Navigator.pushNamed(context,route);
      },
      child: Container(
        decoration: BoxDecoration(
            color: clr,
            borderRadius: BorderRadius.circular(30)
        ),
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon,size: 40,),
            Text(name,style:const TextStyle(fontWeight: FontWeight.w900,fontSize: 20) ,),
          ],
        ),
      ),
    );
  }
}
