import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Order/order.dart';
import 'package:stock_management/Screens/Order/process_order.dart';
import 'package:stock_management/Screens/Shop/area_list.dart';
import 'package:stock_management/Services/DB/area_db.dart';
import 'package:stock_management/Services/DB/shop_db.dart';

import '../Shop/shop.dart';

class OrderPageView extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const OrderPageView({Key? key, required this.userModel, required this.companyModel}) : super(key: key);

  @override
  State<OrderPageView> createState() => _OrderPageViewState();
}

class _OrderPageViewState extends State<OrderPageView>{
  PageController _pageController=PageController();
  var totalShop;
  var totalArea;

  @override
  void initState() {
    super.initState();
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
                  ProcessOrder(userModel: widget.userModel, companyModel: widget.companyModel),
                  Order(userModel: widget.userModel, companyModel: widget.companyModel)
                ],
              ),
            ),
          ],
        )
    );
  }
}
