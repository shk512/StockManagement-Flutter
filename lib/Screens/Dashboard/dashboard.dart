import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Company/company_details.dart';
import 'package:stock_management/Screens/User/profile.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Services/shared_preferences/spf.dart';
import 'package:stock_management/Widgets/dashboard_menu.dart';
import 'package:stock_management/Constants/routes.dart';

import '../../Constants/rights.dart';
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
    if(!CompanyModel.isPackageActive){
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
      return const ErrorScreen(error: "Oops! Company package has been expired.\nContact your company.\nIf you are a company then contact the developer team.");
    }else{
      return CompanyModel.companyName.isEmpty
          ? const Center(child: CircularProgressIndicator(),)
          :Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: (){
              if(UserModel.rights.contains(Rights.viewCompany)||UserModel.rights.contains(Rights.all)){
                Navigator.push(context,MaterialPageRoute(builder: (context)=>const CompanyDetails()));
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.cyan,
              child: CompanyModel.imageUrl.isNotEmpty?Image.network(CompanyModel.imageUrl):const Icon(Icons.warehouse_outlined,color: Colors.white,),)
          ),
          title:  Text(CompanyModel.companyName,style: const TextStyle(color: Colors.white),),
          centerTitle: true,
          actions: [
            PopupMenuButton(
              color: Colors.white,
              onSelected: (value){
                if(value==0){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(userId: UserModel.userId)));
                }
                if(value==1){
                  signOut(context);
                }
              },
                itemBuilder: (context){
                  return [
                    PopupMenuItem(
                      value: 0,
                      child: Row(children: const [Icon(CupertinoIcons.person_crop_circle), SizedBox(width: 5,),Text("View Profile")],),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Row(children: const [Icon(Icons.logout_outlined),SizedBox(width: 5,),Text("SignOut")],),
                    ),
                  ];
                }
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              child: Column(
                children: [
                  UserModel.rights.contains(Rights.viewOrder)||UserModel.rights.contains(Rights.all)
                      ?const DashboardMenu(name: "Track Order", route: Routes.order, icon: Icons.directions, clr: Colors.black26):const SizedBox(),
                  const SizedBox(height: 10,),
                  UserModel.rights.contains(Rights.placeOrder)||UserModel.rights.contains(Rights.all)
                      ? const DashboardMenu(name: "Place Order", route: Routes.area, icon:Icons.add_shopping_cart, clr: Colors.black38):const SizedBox(),
                  const SizedBox(height: 10,),
                  UserModel.rights.contains(Rights.viewStock)||UserModel.rights.contains(Rights.all)
                      ? const DashboardMenu(name: "Stock", route: Routes.stock, icon: Icons.cached_outlined, clr: Colors.black54):const SizedBox(),
                  const SizedBox(height: 10,),
                UserModel.rights.contains(Rights.viewUser)||UserModel.rights.contains(Rights.all)
                      ? const DashboardMenu(name: "User", route: Routes.employee, icon: CupertinoIcons.person_2, clr: Colors.black87):const SizedBox(),
                  const SizedBox(height: 10,),
                UserModel.rights.contains(Rights.viewProduct)||UserModel.rights.contains(Rights.all)
                      ? const DashboardMenu(name: "Product", route: Routes.product, icon: Icons.add_circle_outline, clr: Colors.black54):const SizedBox(),
                  const SizedBox(height: 10,),
                UserModel.rights.contains(Rights.viewShop)||UserModel.rights.contains(Rights.all)
                      ? const DashboardMenu(name: "Shop", route: Routes.shop, icon:Icons.storefront, clr: Colors.black38):const SizedBox(),
                  const SizedBox(height: 10,),
                  UserModel.rights.contains(Rights.viewTransactions)||UserModel.rights.contains(Rights.all)
                      ? const DashboardMenu(name: "Accounts", route: Routes.accounts, icon: Icons.account_balance_outlined, clr: Colors.black26):const SizedBox(),
                ],
              ),
            )
        ),
      );
    }
  }
}
