import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/PageView/normal_page_view.dart';
import 'package:stock_management/Screens/PageView/order_page_view.dart';
import 'package:stock_management/Services/Auth/auth.dart';

import '../../Constants/rights.dart';
import '../../Services/DB/company_db.dart';
import '../../Services/DB/user_db.dart';
import '../../Services/shared_preferences/spf.dart';
import '../Area/user_area.dart';
import '../PageView/shop_page_view.dart';
import '../Product/product.dart';
import '../Splash_Error/error.dart';
import '../Stock/stock.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin{
  Auth auth=Auth();
  CompanyModel _companyModel=CompanyModel();
  UserModel _userModel=UserModel();
  int selectedPage=0;
  List pages=[];

  @override
  void initState() {
    super.initState();
    getUserAndCompanyData();
    Timer(Duration(seconds: 10), () {
      if(_companyModel.companyName.isEmpty){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: "Something error",key: Key("errorScreen"))), (route) => false);
      }
    });
    pages.insert(0, OrderPageView(userModel: _userModel, companyModel: _companyModel,key: Key("orderPageView"),));
    pages.insert(1, NormalPageView(userModel: _userModel, companyModel: _companyModel, page: Product(userModel: _userModel, companyModel: _companyModel,key: Key('product'),)));
    pages.insert(2, NormalPageView(userModel: _userModel, companyModel: _companyModel, page: UserArea(userModel: _userModel, companyModel: _companyModel,key: Key("userArea"))));
    pages.insert(3, NormalPageView(userModel: _userModel, companyModel: _companyModel, page: Stock(userModel: _userModel, companyModel: _companyModel,key: Key("stock"))));
    pages.insert(4, ShopPageView(userModel: _userModel, companyModel: _companyModel,key: Key("shopPageView")));
  }

  getUserAndCompanyData()async{
    var userId=await FirebaseAuth.instance.currentUser!.uid;
    await UserDb(id: userId).getData().then((snapshot)async{
      setState(() {
        _userModel.userId=snapshot["userId"];
        _userModel.companyId=snapshot["companyId"];
        _userModel.name=snapshot["name"];
        _userModel.salary=snapshot["salary"];
        _userModel.mail=snapshot["mail"];
        _userModel.phone=snapshot["phone"];
        _userModel.wallet=snapshot["wallet"];
        _userModel.role=snapshot["role"];
        _userModel.designation=snapshot["designation"];
        _userModel.isDeleted=snapshot["isDeleted"];
        _userModel.area=List.from(snapshot["area"]);
        _userModel.rights=List.from(snapshot["right"]);
      });
      await CompanyDb(id: _userModel.companyId).getData().then((snapshot){
        setState(() {
          _companyModel.imageUrl=snapshot["imageUrl"];
          _companyModel.companyId=snapshot['companyId'];
          _companyModel.contact=snapshot['contact'];
          _companyModel.isPackageActive= snapshot['isPackageActive'];
          _companyModel.packageEndsDate= snapshot['packageEndsDate'];
          _companyModel.companyName= snapshot['companyName'];
          _companyModel.wallet=snapshot['wallet'];
          _companyModel.packageType=snapshot["packageType"];
          _companyModel.whatsApp=snapshot["whatsApp"];
          _companyModel.city=snapshot["city"];
          _companyModel.location=snapshot["geoLocation"];
        });
      }).onError((error, stackTrace){
        SPF.saveUserLogInStatus(false);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"))), (route) => false);
      });
    }).onError((error, stackTrace){
      SPF.saveUserLogInStatus(false);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"))), (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_companyModel.companyName.isEmpty){
      return Scaffold(body: Center(child: CircularProgressIndicator(),),);
    }
    if(_userModel.isDeleted){
      SPF.saveUserLogInStatus(false);
      return ErrorScreen(error: "Oops! Your account is inactive.\nContact your company to activate.");
    }
    if(!_companyModel.isPackageActive){
      return ErrorScreen(error: "Oops! Company package has been expired.");
    }
    else{
      DateTime dateTime=DateTime.parse(DateFormat("yyyy-MM-dd").format(DateTime.now()));
      if(_companyModel.packageEndsDate.isNotEmpty){
        DateTime packageEndDate=DateTime.parse(_companyModel.packageEndsDate);
        if(packageEndDate.isBefore(dateTime)){
          changePackageStatus();
        }
      }
      return Scaffold(
        body: pages[selectedPage],
          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: FloatingActionButton(
            heroTag: "addOrder",
            tooltip: "Place Order",
            onPressed: (){
              if(_userModel.rights.contains(Rights.placeOrder)||_userModel.rights.contains(Rights.all)){
                setState(() {
                  selectedPage=2;
                });
              }
            },
            child: Icon(Icons.add,color: Colors.white,),
          ),
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 4.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    tooltip: "Order",
                    color: selectedPage==0?Colors.brown:Colors.black38,
                    onPressed: (){
                      if(_userModel.rights.contains(Rights.viewOrder)||_userModel.rights.contains(Rights.all)){
                        setState(() {
                          selectedPage=0;
                        });
                      }
                    },
                    icon: Icon(Icons.shopping_cart,)),
                IconButton(
                    tooltip: "Catalog",
                    color: selectedPage==1?Colors.brown:Colors.black38,
                    onPressed: (){
                      if(_userModel.rights.contains(Rights.viewProduct)||_userModel.rights.contains(Rights.all)){
                        setState(() {
                          selectedPage=1;
                        });
                      }
                    },
                    icon: Icon(Icons.dns)),
                SizedBox(width: 30,),
                IconButton(
                    tooltip: "Stock",
                    color: selectedPage==3?Colors.brown:Colors.black38,
                    onPressed: (){
                      if(_userModel.rights.contains(Rights.viewStock)||_userModel.rights.contains(Rights.all)){
                        setState(() {
                          selectedPage=3;
                        });
                      }
                    },
                    icon: Icon(Icons.cached)),
                IconButton(
                    tooltip: "Shop",
                    color: selectedPage==4?Colors.brown:Colors.black38,
                    onPressed: (){
                      if(_userModel.rights.contains(Rights.viewShop)||_userModel.rights.contains(Rights.all)){
                        setState(() {
                          selectedPage=4;
                        });
                      }
                    },
                    icon: Icon(Icons.storefront_outlined)),
              ],
            ),
          ),
      );
    }
  }
  changePackageStatus()async{
    await CompanyDb(id: _companyModel.companyId).updateCompany({"isPackageActive":false}).then((value){
      getUserAndCompanyData();
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen")))));
  }
}
