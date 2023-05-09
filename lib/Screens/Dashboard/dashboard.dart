import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Company/company_details.dart';
import 'package:stock_management/Services/Auth/auth.dart';
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
  CompanyModel _companyModel=CompanyModel();
  UserModel _userModel=UserModel();
  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(_companyModel,_userModel);
   // getProfileStatus();
  }
 /* getProfileStatus(){
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
  }*/

  @override
  Widget build(BuildContext context) {
    if(_userModel.isDeleted){
      return const ErrorScreen(error: "Oops! Account has been deleted");
    }
    if(!_companyModel.isPackageActive){
      return const ErrorScreen(error: "Oops! Company package has been expired.\nContact your company.\nIf you are a company then contact the developer team.");
    }else{
      return _companyModel.companyName.isEmpty
          ? const Center(child: CircularProgressIndicator(),)
          :Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: (){
              if(_userModel.rights.contains(Rights.viewCompany)||_userModel.rights.contains(Rights.all)){
                Navigator.push(context,MaterialPageRoute(builder: (context)=>const CompanyDetails()));
              }
            },
            child: CircleAvatar(
              backgroundColor: Colors.cyan,
              child: _companyModel.imageUrl.isNotEmpty?Image.network(_companyModel.imageUrl):const Icon(Icons.warehouse_outlined,color: Colors.white,),)
          ),
          title:  Text(_companyModel.companyName,style: const TextStyle(color: Colors.white),),
          actions: [
            PopupMenuButton(
              color: Colors.white,
              onSelected: (value){
                if(value==0){
                  Navigator.pushNamed(context, Routes.profile);
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
            child: Column(
                children: [
                  _userModel.rights.contains(Rights.viewOrder)||_userModel.rights.contains(Rights.all)
                      ? DashboardMenu(name: "Track Order", route: Routes.order, icon: Icons.directions, clr: Colors.lightGreen.shade600):const SizedBox(),
                  _userModel.rights.contains(Rights.placeOrder)||_userModel.rights.contains(Rights.all)
                      ? DashboardMenu(name: "Place Order", route: Routes.area, icon:Icons.add_shopping_cart, clr: Colors.lightGreen.shade500):const SizedBox(),
                  _userModel.rights.contains(Rights.viewStock)||_userModel.rights.contains(Rights.all)
                      ? DashboardMenu(name: "Stock", route: Routes.stock, icon: Icons.cached_outlined, clr: Colors.lightGreen.shade400):const SizedBox(),
                  _userModel.rights.contains(Rights.viewUser)||_userModel.rights.contains(Rights.all)
                      ? DashboardMenu(name: "User", route: Routes.employee, icon: CupertinoIcons.person_2, clr: Colors.lightGreen.shade300):const SizedBox(),
                  _userModel.rights.contains(Rights.viewProduct)||_userModel.rights.contains(Rights.all)
                      ? DashboardMenu(name: "Product", route: Routes.product, icon: Icons.add_circle_outline, clr: Colors.lightGreen.shade400):const SizedBox(),
                  _userModel.rights.contains(Rights.viewShop)||_userModel.rights.contains(Rights.all)
                      ? DashboardMenu(name: "Shop", route: Routes.shop, icon:Icons.storefront, clr: Colors.lightGreen.shade500):const SizedBox(),
                  _userModel.rights.contains(Rights.viewReport)||_userModel.rights.contains(Rights.all)
                      ? DashboardMenu(name: "Report", route: Routes.report, icon:Icons.description, clr: Colors.lightGreen.shade600):const SizedBox(),
                  _userModel.rights.contains(Rights.viewTransactions)||_userModel.rights.contains(Rights.all)
                      ? DashboardMenu(name: "Accounts", route: Routes.accounts, icon: Icons.account_balance_outlined, clr: Colors.lightGreen.shade700):const SizedBox(),
                ],
              ),
            )
      );
    }
  }
}
