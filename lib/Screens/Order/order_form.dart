import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/get_data.dart';
import 'package:stock_management/Services/DB/shop_db.dart';

import '../../Models/company_model.dart';

class OrderForm extends StatefulWidget {
  final String shopId;
  const OrderForm({Key? key,required this.shopId}) : super(key: key);

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  String shopName="";
  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid);
    getShopDetails();
  }
  getShopDetails() async{
    await ShopDB(companyId: CompanyModel.companyId, shopId: widget.shopId).getShopDetails().then((value){
      setState(() {
        shopName=value["shopName"];
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: Text(shopName,style: const TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: (){

            },
            icon: const Icon(Icons.add,color: Colors.white,),
            label: const Text("Shop",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
        ),
    );
  }
}
