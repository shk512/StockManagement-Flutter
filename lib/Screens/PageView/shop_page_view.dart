import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Shop/area_list.dart';
import 'package:stock_management/Services/DB/area_db.dart';
import 'package:stock_management/Services/DB/shop_db.dart';

import '../Shop/shop.dart';

class ShopPageView extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const ShopPageView({Key? key, required this.userModel, required this.companyModel}) : super(key: key);

  @override
  State<ShopPageView> createState() => _ShopPageViewState();
}

class _ShopPageViewState extends State<ShopPageView>{
  PageController _pageController=PageController();
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
    return Scaffold(
      body: Column(
        children: [

          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                Shop(userModel: widget.userModel, companyModel: widget.companyModel),
                AreaList(userModel: widget.userModel, companyModel: widget.companyModel),
              ],
            ),
          ),
        ],
      )
    );
  }
}
