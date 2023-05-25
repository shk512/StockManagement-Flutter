import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_management/Screens/Order/add_order_product.dart';
import 'package:stock_management/Services/DB/shop_db.dart';

import '../../Models/company_model.dart';
import '../../Models/order_model.dart';
import '../../Services/DB/order_db.dart';
import '../../Services/DB/product_db.dart';
import '../../Services/DB/report_db.dart';
import '../../utils/snack_bar.dart';
import '../Splash_Error/error.dart';

class EditOrder extends StatefulWidget {
  final OrderModel orderModel;
  final CompanyModel companyModel;
  const EditOrder({Key? key,required this.orderModel,required this.companyModel}) : super(key: key);

  @override
  State<EditOrder> createState() => _EditOrderState();
}

class _EditOrderState extends State<EditOrder> {
  bool isLoading=false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: const Text("Edit Order",style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderProduct(companyModel: widget.companyModel,shopId: widget.orderModel.shopId, orderModel: widget.orderModel,)));
              },
              icon: Icon(Icons.add,color: Colors.white,))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            updateOrder();
          }, label: Text("Update",style: TextStyle(color: Colors.white),)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(),)
          :ListView.builder(
        itemCount: widget.orderModel.products.length,
        itemBuilder: (context,index){
          if(widget.orderModel.products.isEmpty){
            return const Center(child: Text("No Products"),);
          }else{
            return ListTile(
              title: Text("${widget.orderModel.products[index]["productName"]}-${widget.orderModel.products[index]["description"]}"),
              subtitle: Text("Detail: ${widget.orderModel.products[index]["totalQuantity"]}x${widget.orderModel.products[index]["minPrice"]}=${widget.orderModel.products[index]["totalPrice"]}"),
              trailing: IconButton(
                  onPressed: ()async{
                    await ProductDb(companyId: widget.companyModel.companyId, productId: widget.orderModel.products[index]["productId"]).increment(widget.orderModel.products[index]["totalQuantity"]).then((value)async{
                      String formattedDate=DateFormat("yyyy-MM-dd").format(DateTime.parse(widget.orderModel.dateTime));
                      await ReportDb(companyId: widget.companyModel.companyId, productId: widget.orderModel.products[index]["productId"]).decrement(widget.orderModel.products[index]["totalQuantity"], formattedDate).then((value)async{
                        num amount=widget.orderModel.totalAmount-widget.orderModel.products[index]["totalPrice"];
                        await ShopDB(companyId: widget.companyModel.companyId, shopId: widget.orderModel.shopId).updateWallet(-amount).then((value)async{
                          setState(() {
                            widget.orderModel.totalAmount-=widget.orderModel.products[index]["totalPrice"];
                            widget.orderModel.products.removeAt(index);
                            widget.orderModel.balanceAmount=widget.orderModel.totalAmount-widget.orderModel.advanceAmount;
                          });
                          showSnackbar(context, Colors.green.shade300, "Removed");
                        });
                      });
                    });
                  },
                  icon: const Icon(Icons.remove_circle,color: Colors.red,)),
            );
          }
        },
      ),
    );
  }
  updateOrder()async{
    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderModel.orderId).updateOrder({
      "products":widget.orderModel.products,
      "totalAmount":widget.orderModel.totalAmount,
      "balanceAmount":widget.orderModel.balanceAmount
    }).then((value)async {
      if (value == true) {
        showSnackbar(context, Colors.green.shade300, "Updated");
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
