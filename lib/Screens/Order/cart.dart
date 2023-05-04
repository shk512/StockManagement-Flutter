import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_management/Functions/get_data.dart';
import 'package:stock_management/Functions/location.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/order_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Models/order_model.dart';
import '../../Models/user_model.dart';
import '../../Services/DB/product_db.dart';
import '../../utils/routes.dart';

class Cart extends StatefulWidget {
  final List order;
  num totalBill;
  final String shopDetails;
  Cart({Key? key,required this.shopDetails,required this.order,required this.totalBill}) : super(key: key);

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
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid);
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
        centerTitle: true,
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
                itemCount: widget.order.length,
                itemBuilder: (context,index){
                  if(widget.order.isEmpty){
                    return const Center(child: Text("Cart is Empty"),);
                  }else{
                    return ListTile(
                      title: Text("${widget.order[index]["productName"]}-${widget.order[index]["description"]}"),
                      subtitle: Text("Detail: ${widget.order[index]["totalQuantity"]}x${widget.order[index]["minPrice"]}=${widget.order[index]["totalPrice"]}"),
                      trailing: IconButton(
                          onPressed: ()async{
                            widget.order.removeAt(index);
                            setState(() {

                            });
                            await ProductDb(companyId: CompanyModel.companyId, productId: widget.order[index]["productId"]).updateStockAgain(widget.order[index]["totalQuantity"]).then((value){
                              Navigator.pop(context);
                              showSnackbar(context, Colors.cyan, "Added to cart");
                              setState(() {
                                widget.totalBill-=widget.order[index]["totalPrice"];
                              });
                            });
                            showSnackbar(context, Colors.red, "Removed");
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
                      Text("Total Amount: ${widget.totalBill}",style: const TextStyle(fontWeight: FontWeight.w900),)
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
    await OrderDB(companyId: CompanyModel.companyId, orderId: orderId)
        .saveOrder(OrderModel.toJson(
        orderId: orderId,
        userId: UserModel.userId,
        shopDetails: widget.shopDetails,
        status: "Processing".toUpperCase(),
        remarks: remarks,
        desc: "",
        dateTime: DateTime.now().toString(),
        products: widget.order,
        totalAmount: widget.totalBill,
        advanceAmount: advanceAmount,
        concessionAmount: 0,
        balanceAmount: widget.totalBill - advanceAmount,
        lat: lat,
        lng: lng)
    )
        .then((value) {
      if (value == true) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.area, (route) => false);
        showSnackbar(context, Colors.cyan, "Order has been placed");
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
