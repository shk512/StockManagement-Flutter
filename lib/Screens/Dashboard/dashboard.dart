import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_management/Functions/update_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/User/profile.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Services/shared_preferences/spf.dart';
import 'package:stock_management/Widgets/dashboard_menu.dart';
import 'package:stock_management/utils/routes.dart';

import '../../Functions/sign_out.dart';
import '../../Functions/get_data.dart';
import '../Splash_Error/error.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Auth auth=Auth();
  bool isUserDeleted=false;
  bool isCompanyExpired=false;

  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid);
    getProfileStatus();
  }
  getProfileStatus(){
    if(UserModel.isDeleted){
      setState(() {
        isUserDeleted=true;
      });
      SPF.saveUserLogInStatus(false);
    }
    if(CompanyModel.isPackageActive){
      String formattedDate = "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}";
     DateTime currentDate=DateTime.parse(formattedDate);
      DateTime companyPackageDate=DateTime.parse(CompanyModel.packageEndsDate);
      print(currentDate);
      print(companyPackageDate);
      if(CompanyModel.packageEndsDate!=""){
        if(companyPackageDate.isBefore(companyPackageDate)){
          CompanyModel.isPackageActive=false;
          CompanyModel.packageEndsDate="";
          updateCompanyData(context);
        }
      }
    }else{
      setState(() {
        isCompanyExpired=true;
      });
      SPF.saveUserLogInStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(isUserDeleted){
      return const ErrorScreen(error: "Oops! Account has been deleted");
    }
    if(isCompanyExpired){
      return const ErrorScreen(error: "Oops! Company package has been expired");
    }else{
      return Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (context)=>Profile(userId: FirebaseAuth.instance.currentUser!.uid)));
            },
            child: const Icon(CupertinoIcons.person_crop_circle,color: Colors.white,),
          ),
          title: InkWell(
            onTap: (){
              if(UserModel.role=="manager".toUpperCase()){
                Navigator.pushNamed(context, Routes.companyDetails);
              }
            },
            child: Text(CompanyModel.companyName,style: const TextStyle(color: Colors.white),),
          ),
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
                  DashboardMenu(name: "Track Order", route: Routes.order, icon: Icons.directions, clr: Colors.black26),
                  SizedBox(height: 10,),
                  DashboardMenu(name: "Stock", route: Routes.stock, icon: Icons.cached_outlined, clr: Colors.black38),
                  SizedBox(height: 10,),
                  DashboardMenu(name: "User", route: Routes.employee, icon: CupertinoIcons.person_2, clr: Colors.black54),
                  SizedBox(height: 10,),
                  DashboardMenu(name: "Product", route: Routes.product, icon: Icons.add_circle_outline, clr: Colors.black54),
                  SizedBox(height: 10,),
                  DashboardMenu(name: "Area/Shops", route: Routes.area, icon:Icons.storefront, clr: Colors.black38),
                  SizedBox(height: 10,),
                  DashboardMenu(name: "Accounts", route: Routes.accounts, icon: Icons.account_balance_outlined, clr: Colors.black26),
                ],
              ),
            )
        ),
      );
    }

  }
}
