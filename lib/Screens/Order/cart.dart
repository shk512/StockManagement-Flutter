import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:stock_management/Functions/location.dart';
import 'package:stock_management/Models/account_model.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Area/area.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/account_db.dart';
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
  const Cart({Key? key,required this.shopDetails,required this.shopId,required this.userModel,required this.companyModel}) : super(key: key);

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
    getCurrentLocation(context).then((value){
      lat=value.latitude;
      lng=value.longitude;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: const Text("Cart",style: TextStyle(color: Colors.white),),
      ),
      floatingActionButton: InkWell(
        onTap: (){
          placeOrder();
          setState(() {
            isLoading=true;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.cyan
          ),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Text("CheckOut",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(),)
          :Column(
        children:[ 
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: OrderModel.products.length,
                itemBuilder: (context,index){
                  if(OrderModel.products.isEmpty){
                    return const Center(child: Text("Cart is Empty"),);
                  }else{
                    return ListTile(
                      title: Text("${OrderModel.products[index]["productName"]}-${OrderModel.products[index]["description"]}"),
                      subtitle: Text("Detail: ${OrderModel.products[index]["totalQuantity"]}x${OrderModel.products[index]["minPrice"]}=${OrderModel.products[index]["totalPrice"]}"),
                      trailing: IconButton(
                          onPressed: ()async{
                            await ProductDb(companyId: widget.companyModel.companyId, productId: OrderModel.products[index]["productId"]).increment(OrderModel.products[index]["totalQuantity"]).then((value)async{
                              String formattedDate=DateFormat("yyyy-MM-dd").format(DateTime.now());
                              await ReportDb(companyId: widget.companyModel.companyId, productId: OrderModel.products[index]["productId"]).decrement(OrderModel.products[index]["totalQuantity"], formattedDate).then((value){
                                setState(() {
                                  OrderModel.totalAmount=OrderModel.totalAmount-OrderModel.products[index]["totalPrice"];
                                  OrderModel.products.removeAt(index);
                                });
                                showSnackbar(context, Colors.cyan, "Removed");
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
                              advanceAmount=int.parse(val);
                            },
                          ),
                      const SizedBox(height: 10,),
                      Text("Total Amount: ${OrderModel.totalAmount}",style: const TextStyle(fontWeight: FontWeight.w900),)
                    ],
                  ),
                  ),
                )),
        ],
      ),
    );
  }
  placeOrder() async {
    String orderId = DateTime
        .now()
        .microsecondsSinceEpoch
        .toString();
    await OrderDB(companyId: widget.companyModel.companyId, orderId: orderId)
        .saveOrder(OrderModel.toJson(
        orderId: orderId,
        userId: widget.userModel.userId,
        shopId: widget.shopId,
        shopDetails: widget.shopDetails,
        status: "Processing".toUpperCase(),
        remarks: remarks,
        desc: "",
        dateTime: DateTime.now().toString(),
        products: OrderModel.products,
        totalAmount: OrderModel.totalAmount,
        advanceAmount: advanceAmount,
        concessionAmount: 0,
        balanceAmount: OrderModel.totalAmount - advanceAmount,
        location: LatLng(lat, lng),
        deliverId: ''
    )
    ).then((value)async {
      if (value == true) {
        await UserDb(id: widget.userModel.userId).updateWalletBalance(advanceAmount).then((value) async{
          await ShopDB(companyId: widget.companyModel.companyId, shopId: widget.shopId).updateWallet(OrderModel.totalAmount-advanceAmount).then((value)async{
            String tId=DateTime.now().microsecondsSinceEpoch.toString();
            await AccountDb(companyId: widget.companyModel.companyId, transactionId: tId).saveTransaction(
                AccountModel.toJson(
                    transactionId: tId,
                    transactionBy: widget.userModel.userId,
                    desc: widget.shopDetails,
                    narration: Narration.minus,
                    amount: advanceAmount,
                    type: "Cash",
                    dateTime: DateTime.now().toString())).then((value){
              Navigator.pop(context);
              Navigator.pop(context);
              showSnackbar(context, Colors.cyan, "Order has been placed");
              setState(() {
                OrderModel.products=[];
                OrderModel.totalAmount=0;
              });
            });
            });
        });
      } else {
        setState(() {
          isLoading=false;
        });
        showSnackbar(context, Colors.red, "Error");
      }
    }).onError((error, stackTrace) {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ErrorScreen(error: error.toString())));
    });
  }
}
