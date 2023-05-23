import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Shop/2_active_shop.dart';
import 'package:stock_management/Screens/Shop/3_inactive_shop.dart';
import 'package:stock_management/Services/DB/area_db.dart';
import 'package:stock_management/Services/DB/shop_db.dart';

import '../../Constants/rights.dart';
import '../../Functions/sign_out.dart';
import '../Area/area.dart';
import '../Company/company_details.dart';
import '../Report/display_product.dart';
import '../Shop/1_shop.dart';
import '../Transaction/transaction.dart';
import '../User/user.dart';
import '../User/view_user.dart';

class ShopPageView extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const ShopPageView({Key? key, required this.userModel, required this.companyModel}) : super(key: key);

  @override
  State<ShopPageView> createState() => _ShopPageViewState();
}

class _ShopPageViewState extends State<ShopPageView>{
  var totalShop;
  var totalArea;

  @override
  void initState() {
    super.initState();
    getCounts();
  }
  getCounts() async{
    await ShopDB(companyId: widget.companyModel.companyId, shopId: "").getTotalShops().then((value){
      setState(() {
        totalShop=value;
      });
    });
    await AreaDb(areaId: "", companyId: widget.companyModel.companyId).getAreaCounts().then((value){
      setState(() {
        totalArea=value;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    leading: InkWell(
                        onTap: (){
                          if(widget.userModel.rights.contains(Rights.viewCompany)||widget.userModel.rights.contains(Rights.all)){
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>CompanyDetails(userModel: widget.userModel,companyModel: widget.companyModel,)));
                          }
                        },
                        child: widget.companyModel.imageUrl.isNotEmpty
                            ?CircleAvatar(
                          backgroundImage: NetworkImage(widget.companyModel.imageUrl),
                          radius: 3,
                        )
                            :Icon(Icons.image)
                    ),
                    title: Text(widget.companyModel.companyName,style: const TextStyle(fontWeight: FontWeight.w900,color: Colors.white),),
                    actions: [
                      PopupMenuButton(
                          color: Colors.white,
                          onSelected: (value){
                            if(value==0){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewUser(userId: widget.userModel.userId, userModel: widget.userModel, companyModel: widget.companyModel)));
                            }
                            if(value==1){
                              if(widget.userModel.rights.contains(Rights.all)||widget.userModel.rights.contains(Rights.viewCompany)){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Area(companyModel: widget.companyModel, userModel: widget.userModel,)));
                              }
                            }
                            if(value==2){
                              if(widget.userModel.rights.contains(Rights.all)||widget.userModel.rights.contains(Rights.viewReport)){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>DisplayProduct(companyModel: widget.companyModel)));
                              }
                            }
                            if(value==3){
                              if(widget.userModel.rights.contains(Rights.all)||widget.userModel.rights.contains(Rights.viewTransactions)){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Accounts(companyModel: widget.companyModel, userModel: widget.userModel)));
                              }
                            }
                            if(value==4){
                              if(widget.userModel.rights.contains(Rights.all)||widget.userModel.rights.contains(Rights.viewUser)){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Employee(companyModel: widget.companyModel, userModel: widget.userModel)));
                              }
                            }
                            if(value==5){
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
                                child: Row(children: const [Icon(Icons.pin_drop_outlined,color: Colors.black54,), SizedBox(width: 5,),Text("Area")],),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Row(children: const [Icon(Icons.receipt_long,color: Colors.black54,), SizedBox(width: 5,),Text("Report")],),
                              ),
                              PopupMenuItem(
                                value: 3,
                                child: Row(children: const [Icon(Icons.account_balance,color: Colors.black54,), SizedBox(width: 5,),Text("Account")],),
                              ),
                              PopupMenuItem(
                                value: 4,
                                child: Row(children: const [Icon(CupertinoIcons.person_3_fill,color: Colors.black54,), SizedBox(width: 5,),Text("User")],),
                              ),
                              PopupMenuItem(
                                value: 5,
                                child: Row(children: const [Icon(Icons.logout_outlined,color: Colors.black54,),SizedBox(width: 5,),Text("SignOut")],),
                              ),
                            ];
                          }
                      ),
                    ],
                    pinned: true,
                    floating: true,
                    bottom: TabBar(
                      tabs: [
                        Tab(child: Text('All')),
                        Tab(child: Text('Active')),
                        Tab(child: Text("InActive")),
                      ],
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: <Widget>[
                  Shop(userModel: widget.userModel, companyModel: widget.companyModel),
                  ActiveShop(userModel: widget.userModel, companyModel: widget.companyModel),
                  InActiveShop(userModel: widget.userModel, companyModel: widget.companyModel)
                ],
              ),
            )
        ));
  }
}
