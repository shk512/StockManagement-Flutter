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
  final String orderId;
  final CompanyModel companyModel;
  const EditOrder({Key? key,required this.orderId,required this.companyModel}) : super(key: key);

  @override
  State<EditOrder> createState() => _EditOrderState();
}

class _EditOrderState extends State<EditOrder> {
  DocumentSnapshot? snapshot;
  bool isLoading=false;
  num balanceAmount=0;

  getOrderData()async{
    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderId).getOrderById().then((value) {
      setState(() {
        snapshot = value;
        OrderModel.products=List.from(value["products"]);
        OrderModel.totalAmount=value["totalAmount"];
        balanceAmount=value["balanceAmount"];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getOrderData();
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
                Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderProduct(companyModel: widget.companyModel,shopId: snapshot!["shopId"],)));
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
        itemCount: OrderModel.products.length,
        itemBuilder: (context,index){
          if(OrderModel.products==[]){
            return const Center(child: Text("No Products"),);
          }else{
            return ListTile(
              title: Text("${OrderModel.products[index]["productName"]}-${OrderModel.products[index]["description"]}"),
              subtitle: Text("Detail: ${OrderModel.products[index]["totalQuantity"]}x${OrderModel.products[index]["minPrice"]}=${OrderModel.products[index]["totalPrice"]}"),
              trailing: IconButton(
                  onPressed: ()async{
                    await ProductDb(companyId: widget.companyModel.companyId, productId: OrderModel.products[index]["productId"]).increment(OrderModel.products[index]["totalQuantity"]).then((value)async{
                      String formattedDate=DateFormat("yyyy-MM-dd").format(DateTime.parse(snapshot!["dateTime"]));
                      await ReportDb(companyId: widget.companyModel.companyId, productId: OrderModel.products[index]["productId"]).decrement(OrderModel.products[index]["totalQuantity"], formattedDate).then((value)async{
                        num amount=OrderModel.totalAmount-OrderModel.products[index]["totalPrice"];
                        await ShopDB(companyId: widget.companyModel.companyId, shopId: snapshot!["shopId"]).updateWallet(-amount).then((value)async{
                          setState(() {
                            OrderModel.totalAmount=OrderModel.totalAmount-OrderModel.products[index]["totalPrice"];
                            OrderModel.products.removeAt(index);
                            balanceAmount=OrderModel.totalAmount-snapshot!["advanceAmount"];
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
    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderId).updateOrder({
      "products":OrderModel.products,
      "totalAmount":OrderModel.totalAmount,
      "balanceAmount":balanceAmount
    }).then((value)async {
      if (value == true) {
        showSnackbar(context, Colors.green.shade300, "Updated");
        setState(() {
          OrderModel.products=[];
          OrderModel.totalAmount=0;
        });
      } else {
        setState(() {
          isLoading=false;
        });
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace) {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ErrorScreen(error: error.toString())));
    });
  }
}
