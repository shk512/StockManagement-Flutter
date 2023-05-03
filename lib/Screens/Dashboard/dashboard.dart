import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/update_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/User/profile.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Widgets/dashboard_menu.dart';
import 'package:stock_management/utils/routes.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Functions/sign_out.dart';
import '../../Functions/get_data.dart';

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
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid);
  }
  getProfileStatus()async{
    if(UserModel.isDeleted){
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
      showSnackbar(context, Colors.red, "Oops! Account has been deleted");
    }
    if(CompanyModel.isPackageActive){
      DateTime date=DateTime.parse(CompanyModel.packageEndsDate);
      if(date.isBefore(DateTime.now())){
        CompanyModel.isPackageActive=false;
        CompanyModel.packageEndsDate="";
        updateCompanyData(context);
      }
    }else{
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
      showSnackbar(context, Colors.red, "Oops! Company package has been expired");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.push(context,MaterialPageRoute(builder: (context)=>Profile(userId: FirebaseAuth.instance.currentUser!.uid)));
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
            children: const [
              DashboardMenu(name: "Order", route: Routes.order, icon: Icons.shopping_cart_outlined, clr: Colors.red),
              SizedBox(height: 10,),
              DashboardMenu(name: "Stock", route: Routes.stock, icon: Icons.cached_outlined, clr: Colors.green),
              SizedBox(height: 10,),
              DashboardMenu(name: "User", route: Routes.employee, icon: CupertinoIcons.person_2, clr: Colors.green),
              SizedBox(height: 10,),
              DashboardMenu(name: "Product", route: Routes.product, icon: Icons.add_circle_outline, clr: Colors.green),
              SizedBox(height: 10,),
              DashboardMenu(name: "Area/Shops", route: Routes.area, icon: Icons.storefront, clr: Colors.purpleAccent),
              SizedBox(height: 10,),
              DashboardMenu(name: "Accounts", route: Routes.accounts, icon: Icons.account_balance_outlined, clr: Colors.grey),
            ],
          ),
        )
      ),
    );
  }
}
