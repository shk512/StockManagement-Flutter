import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stock_management/Functions/create_transaction.dart';
import 'package:stock_management/Functions/location.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/order_db.dart';
import 'package:stock_management/Services/DB/report_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Constants/narration.dart';
import '../../Models/order_model.dart';
import '../../Models/user_model.dart';
import '../../Services/DB/product_db.dart';
import '../../Services/DB/shop_db.dart';

class Cart extends StatefulWidget {
  final String shopId;
  final String shopDetails;
  final CompanyModel companyModel;
  final UserModel userModel;
  final OrderModel orderModel;
  const Cart({Key? key,required this.orderModel, required this.shopDetails,required this.shopId,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  bool isLoading=false;
  String remarks="";
  num advanceAmount=0;
  var lat;
  var lng;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading:IconButton(
          onPressed: (){
            Navigator.pop(context, widget.orderModel);
          },
          icon: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: const Text("Cart",style: TextStyle(color: Colors.white),),
        actions: [
          ElevatedButton(
            onPressed: ()async{
              await getCurrentLocation(context).then((value){
                lat=value.latitude;
                lng=value.longitude;
              });
              if(lat!=0&&lng!=0){
                placeOrder();
              }else{
                showSnackbar(context, Colors.red.shade400, "Oops! App doesn't able to pick location. So, Order couldn't post.");
              }
              setState(() {
                isLoading=true;
              });
            },
            child: const Text("Place Order",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(),)
          :Column(
        children:[ 
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: widget.orderModel.products.length,
                itemBuilder: (context,index){
                  if(widget.orderModel.products.isEmpty){
                    return const Center(child: Text("Cart is Empty"),);
                  }else{
                    return ListTile(
                      title: Text("${widget.orderModel.products[index]["productName"]}-${widget.orderModel.products[index]["description"]}"),
                      subtitle: Text("Detail: ${widget.orderModel.products[index]["totalQuantity"]}x${widget.orderModel.products[index]["minPrice"]}=${widget.orderModel.products[index]["totalPrice"]}"),
                      trailing: IconButton(
                          onPressed: ()async{
                            await ProductDb(companyId: widget.companyModel.companyId, productId: widget.orderModel.products[index]["productId"]).increment(widget.orderModel.products[index]["totalQuantity"]).then((value)async{
                              String formattedDate=DateFormat("yyyy-MM-dd").format(DateTime.now());
                              await ReportDb(companyId: widget.companyModel.companyId, productId: widget.orderModel.products[index]["productId"]).decrement(widget.orderModel.products[index]["totalQuantity"], formattedDate).then((value){
                                setState(() {
                                  widget.orderModel.totalAmount=widget.orderModel.totalAmount-widget.orderModel.products[index]["totalPrice"];
                                  widget.orderModel.products.removeAt(index);
                                });
                                showSnackbar(context, Colors.green.shade300, "Removed");
                              });
                            });

                          },
                          icon: const Icon(Icons.remove_circle,color: Colors.red,)),
                    );
                  }
                }),
            ),
            const SizedBox(height: 10,),
            Expanded(
              flex: 2,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                       TextField(
                            maxLines: 3,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Remarks (if-any)",
                            ),
                            onChanged: (val){
                              remarks=val;
                            },
                       ),
                      const SizedBox(height: 10,),
                    TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Advance amount (if-any)",
                            ),
                            onChanged: (val){
                              advanceAmount=val.isEmpty?0:int.parse(val);
                            },
                          ),
                      const SizedBox(height: 10,),
                      Text("Total Amount: ${widget.orderModel.totalAmount}",style: const TextStyle(fontWeight: FontWeight.w900),)
                    ],
                  ),
                  ),
                )),
        ],
      ),
    );
  }
  placeOrder() async {
    widget.orderModel.orderId = DateTime
        .now()
        .microsecondsSinceEpoch
        .toString();
    widget.orderModel.orderBy=widget.userModel.userId;
    widget.orderModel.shopId=widget.shopId;
    widget.orderModel.shopDetails=widget.shopDetails;
    widget.orderModel.status="Processing".toUpperCase();
    widget.orderModel.remarks=remarks;
    widget.orderModel.dateTime=DateTime.now().toString();
    widget.orderModel.advanceAmount=advanceAmount;
    widget.orderModel.balanceAmount=widget.orderModel.totalAmount-advanceAmount;
    widget.orderModel.location=GeoPoint(lat, lng);
    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderModel.orderId)
        .saveOrder(
        widget.orderModel.toJson()
    ).then((value)async {
      if (value == true) {
        await UserDb(id: widget.userModel.userId).updateWalletBalance(advanceAmount).then((value) async{
          await ShopDB(companyId: widget.companyModel.companyId, shopId: widget.shopId).updateWallet(widget.orderModel.totalAmount-advanceAmount).then((value)async{
            if(advanceAmount!=0){
              accountTransaction(Narration.minus, advanceAmount, "Cash", widget.shopDetails, widget.companyModel.companyId, widget.userModel.userId, context).then((value){
              });
            }
            Navigator.pop(context);
            Navigator.pop(context);
            showSnackbar(context, Colors.green.shade300, "Order has been placed");
          });
        });
      } else {
        setState(() {
          isLoading=false;
        });
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace) {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
    });
  }
}
