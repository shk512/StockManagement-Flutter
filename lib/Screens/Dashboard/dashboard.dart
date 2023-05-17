import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Company/company_details.dart';
import 'package:stock_management/Screens/User/view_user.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Widgets/dashboard_menu.dart';

import '../../Constants/rights.dart';
import '../../Functions/sign_out.dart';
import '../../Services/DB/company_db.dart';
import '../../Services/DB/user_db.dart';
import '../../Services/shared_preferences/spf.dart';
import '../Area/area.dart';
import '../Order/order.dart';
import '../Product/product.dart';
import '../Report/display_product.dart';
import '../Shop/shop.dart';
import '../Splash_Error/error.dart';
import '../Stock/stock.dart';
import '../Transaction/transaction.dart';
import '../User/user.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Auth auth=Auth();
  CompanyModel _companyModel=CompanyModel();
  UserModel _userModel=UserModel();
  int selectedPage=0;

  @override
  void initState() {
    super.initState();
    getUserAndCompanyData();
    matchList();
  }
  matchList()async{
    for(var area in _userModel.area){
      if(_companyModel.area.contains(area)){
        await UserDb(id: _userModel.userId).deleteUserArea(area);
      }
    }
  }
  getUserAndCompanyData()async{
    await UserDb(id: FirebaseAuth.instance.currentUser!.uid).getData().then((snapshot)async{
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
          _companyModel.area=List.from(snapshot['area']);
          _companyModel.wallet=snapshot['wallet'];
          _companyModel.packageType=snapshot["packageType"];
          _companyModel.whatsApp=snapshot["whatsApp"];
          _companyModel.city=snapshot["city"];
          _companyModel.location=snapshot["geoLocation"];
        });
      }).onError((error, stackTrace){
        SPF.saveUserLogInStatus(false);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())), (route) => false);
      });
    }).onError((error, stackTrace){
      SPF.saveUserLogInStatus(false);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())), (route) => false);
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
          appBar: AppBar(
            leading: GestureDetector(
                onTap: (){
                  if(_userModel.rights.contains(Rights.viewCompany)||_userModel.rights.contains(Rights.all)){
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>CompanyDetails(userModel: _userModel,companyModel: _companyModel,)));
                  }
                },
                child: _companyModel.imageUrl.isNotEmpty
                    ?CircleAvatar(
                  backgroundImage: NetworkImage(_companyModel.imageUrl),
                  radius: 3,
                )
                    :Icon(Icons.image)
            ),
            title: Text(_companyModel.companyName,style: const TextStyle(fontWeight: FontWeight.w900,color: Colors.white),),
            actions: [
              PopupMenuButton(
                  color: Colors.white,
                  onSelected: (value){
                    if(value==0){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewUser(userId: _userModel.userId, userModel: _userModel, companyModel: _companyModel)));
                    }
                    if(value==1){
                      signOut(context);
                    }
                  },
                  itemBuilder: (context){
                    return [
                      PopupMenuItem(
                        value: 0,
                        child: Row(children: const [Icon(CupertinoIcons.person_crop_circle,color: Colors.black54,), SizedBox(width: 5,),Text("View Profile")],),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Row(children: const [Icon(Icons.logout_outlined,color: Colors.black54,),SizedBox(width: 5,),Text("SignOut")],),
                      ),
                    ];
                  }
              ),
            ],
          ),
         /* floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            tooltip: "Place Order",
              onPressed: (){
              if(_userModel.rights.contains(Rights.placeOrder)||_userModel.rights.contains(Rights.all)){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Area(companyModel: _companyModel, userModel: _userModel)));
              }
              },
            child: Icon(Icons.add,color: Colors.white,),
          ),
          bottomNavigationBar: BottomAppBar(
            shape: CircularNotchedRectangle(),
            notchMargin: 4.0,
            child: Row(
              children: [

              ],
            ),
          ),*/
          body: SingleChildScrollView(
            child: Column(
              children: [
                _userModel.rights.contains(Rights.viewOrder)||_userModel.rights.contains(Rights.all)
                    ? DashboardMenu(name: "Track Order", route: Order(userModel: _userModel,companyModel: _companyModel,), icon: Icons.directions, clr: Colors.brown.shade300):const SizedBox(),
                _userModel.rights.contains(Rights.placeOrder)||_userModel.rights.contains(Rights.all)
                    ? DashboardMenu(name: "Place Order", route: Area(companyModel: _companyModel,userModel: _userModel,), icon:Icons.add_shopping_cart, clr: Colors.brown.shade300):const SizedBox(),
                _userModel.rights.contains(Rights.viewStock)||_userModel.rights.contains(Rights.all)
                    ? DashboardMenu(name: "Stock", route: Stock(userModel: _userModel,companyModel: _companyModel,), icon: Icons.cached_outlined, clr: Colors.brown.shade300):const SizedBox(),
                _userModel.rights.contains(Rights.viewUser)||_userModel.rights.contains(Rights.all)
                    ? DashboardMenu(name: "User", route: Employee(companyModel: _companyModel,userModel: _userModel,), icon: CupertinoIcons.person_2, clr: Colors.brown.shade300):const SizedBox(),
                _userModel.rights.contains(Rights.viewProduct)||_userModel.rights.contains(Rights.all)
                    ? DashboardMenu(name: "Product", route: Product(userModel: _userModel,companyModel: _companyModel,), icon: Icons.add_circle_outline, clr: Colors.brown.shade300):const SizedBox(),
                _userModel.rights.contains(Rights.viewShop)||_userModel.rights.contains(Rights.all)
                    ? DashboardMenu(name: "Shop", route: Shop(userModel: _userModel,companyModel: _companyModel,), icon:Icons.storefront, clr: Colors.brown.shade300):const SizedBox(),
                _userModel.rights.contains(Rights.viewReport)||_userModel.rights.contains(Rights.all)
                    ? DashboardMenu(name: "Report", route: DisplayProduct(companyModel: _companyModel,), icon:Icons.description, clr: Colors.brown.shade300):const SizedBox(),
                _userModel.rights.contains(Rights.viewTransactions)||_userModel.rights.contains(Rights.all)
                    ? DashboardMenu(name: "Accounts", route: Accounts(companyModel: _companyModel, userModel: _userModel,), icon: Icons.account_balance_outlined, clr: Colors.brown.shade300):const SizedBox(),
              ],
            ),
          )
      );
    }
  }
  changePackageStatus()async{
    await CompanyDb(id: _companyModel.companyId).updateCompany({"isPackageActive":false}).then((value){
      getUserAndCompanyData();
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
  }
}
