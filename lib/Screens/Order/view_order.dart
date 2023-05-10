import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Constants/narration.dart';
import 'package:stock_management/Functions/open_map.dart';
import 'package:stock_management/Models/order_model.dart';
import 'package:stock_management/Screens/Order/edit_order.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/order_db.dart';
import 'package:stock_management/Services/DB/shop_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/Widgets/num_field.dart';
import 'package:stock_management/Widgets/row_info_display.dart';
import 'package:stock_management/utils/enum.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Constants/rights.dart';
import '../../Models/account_model.dart';
import '../../Models/company_model.dart';
import '../../Models/user_model.dart';
import '../../Services/DB/account_db.dart';

class ViewOrder extends StatefulWidget {
  final String orderId;
  final CompanyModel companyModel;
  final UserModel userModel;
  const ViewOrder({Key? key,required this.orderId,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  DocumentSnapshot? orderSnapshot;
  DocumentSnapshot? shopSnapshot;
  GeoPoint orderLocation=GeoPoint(0,0);
  GeoPoint shopLocation=GeoPoint(0, 0);

  @override
  void initState() {
    super.initState();
    getOrderData();
  }
  getOrderData() async{
    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderId).getOrderById().then((value)async{
      setState(() {
        orderSnapshot=value;
        OrderModel.products=List.from(value["products"]);
        OrderModel.totalAmount=value["totalAmount"];
        orderLocation=value["geoLocation"];
      });
      await ShopDB(companyId: widget.companyModel.companyId, shopId: value["shopId"]).getShopDetails().then((value){
        setState(() {
          shopSnapshot=value;
          shopLocation=value["geoLocation"];
        });
      }).onError((error, stackTrace)=>Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
    }).onError((error, stackTrace)=>Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
  }

  @override
  Widget build(BuildContext context) {
    if(orderSnapshot==null){
      return const Center(child: CircularProgressIndicator(),);
    }else{
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: const Icon(CupertinoIcons.back,color: Colors.white,),
          ),
          title: Text(orderSnapshot!["orderId"],style: const TextStyle(color: Colors.white),),
          actions: [
            orderSnapshot!["status"]!="deliver".toUpperCase()
                ?IconButton(
                onPressed: (){
                  if(widget.userModel.rights.contains(Rights.editOrder)||widget.userModel.rights.contains(Rights.all)){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>EditOrder(orderId: widget.orderId,companyModel: widget.companyModel,)));
                    }
                },
                icon: const Icon(Icons.edit,color: Colors.white,))
                :const SizedBox(),
            orderSnapshot!["status"]=="Processing".toUpperCase()
                ?IconButton(
              tooltip: "Navigate Order",
                onPressed: (){
                  try{
                    if(widget.userModel.rights.contains(Rights.orderNavigation)||widget.userModel.rights.contains(Rights.all))
                    openMap(orderLocation.latitude, orderLocation.longitude);
                  }catch(e){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: e.toString())));
                  }
                },
                icon: const Icon(Icons.navigation_outlined,color: Colors.white,))
                :orderSnapshot!["status"]=="dispatch".toUpperCase()
                  ?IconButton(
                  tooltip: "Navigate Shop",
                  onPressed: (){
                    try{
                     if(widget.userModel.rights.contains(Rights.orderNavigation)||widget.userModel.rights.contains(Rights.all)){
                        openMap(shopLocation.latitude, shopLocation.longitude);
                     }
                    }catch(e){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: e.toString())));
                    }
                  },
                  icon: const Icon(Icons.navigation_outlined,color: Colors.white,))
                :const SizedBox(),
            IconButton(
                onPressed: (){

                },
                icon: Icon(Icons.download,color: Colors.white,),
            )
          ],
        ),
        floatingActionButton: orderSnapshot!["status"]=="processing".toUpperCase()
            ?FloatingActionButton.extended(
          onPressed: (){
            if(widget.userModel.rights.contains(Rights.dispatchOrder)||widget.userModel.rights.contains(Rights.all)){
              updateOrderStatus("Dispatch");
            }
          },
          label: const Text("Dispatch",style: TextStyle(color: Colors.white),),
        )
            :orderSnapshot!["status"]=="dispatch".toUpperCase()
                ?FloatingActionButton.extended(
          onPressed: (){
            if(widget.userModel.rights.contains(Rights.deliverOrder)||widget.userModel.rights.contains(Rights.all)){
              deliverOrder();
            }
          },
          label: const Text("Deliver",style: TextStyle(color: Colors.white),),
        )
            :const SizedBox(),
        body: Column(
            children:[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    children: [
                      RowInfoDisplay(value: orderSnapshot!["shopDetails"], label: "Shop Details"),
                      RowInfoDisplay(value: orderSnapshot!["dateTime"], label: "Order Date"),
                      RowInfoDisplay(value: orderSnapshot!["remarks"], label: "Remarks"),
                      RowInfoDisplay(value: orderSnapshot!["totalAmount"].toString(), label: "Total Amount"),
                      RowInfoDisplay(value: orderSnapshot!["advanceAmount"].toString(), label: "Receive Amount"),
                      RowInfoDisplay(value: orderSnapshot!["concessionAmount"].toString(), label: "Concession Amount"),
                      RowInfoDisplay(value: orderSnapshot!["balanceAmount"].toString(), label: "Balance Amount"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                    itemCount: OrderModel.products.length,
                    itemBuilder: (context,index){
                      if(OrderModel.products.isEmpty){
                        return const Center(child: Text("Cart is Empty"),);
                      }else{
                        return ListTile(
                          title: Text("${OrderModel.products[index]["productName"]}-${OrderModel.products[index]["description"]}"),
                          subtitle: Text("Detail: ${OrderModel.products[index]["totalQuantity"]}x${OrderModel.products[index]["minPrice"]}=${OrderModel.products[index]["totalPrice"]}"),
                          trailing: ClipOval(
                          child: SizedBox(
                            height: 30,
                            width: 30,
                            child: Material(
                            color: Colors.cyan,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "${OrderModel.products[index]["totalQuantity"]}",style: TextStyle(fontSize:16,fontWeight: FontWeight.w900,color: Colors.white),),
                            ),
                            //Icon(Icons.brightness_1_outlined,size: 30,semanticLabel:"${OrderModel.products[index]["totalQuantity"]}" ,)
                            //Text("${OrderModel.products[index]["totalQuantity"]}",style: TextStyle(fontWeight: FontWeight.w900),),
                      ),
                          )));
                      }
                    }),
              ),
            ],
          ),
      );
    }
  }
  updateOrderStatus(String status)async{
    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderId).updateOrder({
      "status": status.toUpperCase()
    }).then((value){
      if(value==true){
        setState(() {
          OrderModel.products=[];
          OrderModel.totalAmount=0;
        });
        Navigator.pop(context);
        showSnackbar(context, Colors.cyan, status);
      }else{
        showSnackbar(context, Colors.red, "Error");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  deliverOrder(){
    TextEditingController amount=TextEditingController();
    TextEditingController concession=TextEditingController();
    TextEditingController detail=TextEditingController();
    final formKey=GlobalKey<FormState>();
    TransactionType type=TransactionType.cash;

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Execute Order"),
            content: Form(
              key: formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                            title: Text(
                              "Cash",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            leading: Radio(
                                value: TransactionType.cash,
                                groupValue: type,
                                onChanged: (value) {
                                  setState(() {
                                    type = value!;
                                  });
                                })
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                            title: Text(
                              "Online",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            leading: Radio(
                                value: TransactionType.online,
                                groupValue: type,
                                onChanged: (value) {
                                  setState(() {
                                    type = value!;
                                  });
                                })
                        ),
                      )
                    ],
                  ),
                  NumField(icon: Icon(Icons.onetwothree_outlined), ctrl: amount, hintTxt: "In digits", labelTxt: "Amount Received"),
                  NumField(icon: Icon(Icons.onetwothree_outlined), ctrl: concession, hintTxt: "In digits", labelTxt: "Concession Amount"),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Details (if-any)",
                    ),
                    controller: detail,
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel",style: TextStyle(color: Colors.white),)),
              ElevatedButton(
                  onPressed: ()async{
                    Navigator.pop(context);
                    String tempType="";
                    if(type==TransactionType.cash){
                      tempType="Cash";
                    }else{
                      tempType="Online";
                    }
                    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderId).updateOrder({
                      "advanceAmount":orderSnapshot!["advanceAmount"]+int.parse(amount.text),
                      "balanceAmount":orderSnapshot!["balanceAmount"]-int.parse(amount.text)-int.parse(concession.text),
                      "concessionAmount": int.parse(concession.text),
                      "description":detail.text,
                      "deliverBy":widget.userModel.userId
                    }).then((value){
                      createTransaction(shopSnapshot!["shopId"],orderSnapshot!["shopDetails"],Narration.plus, int.parse(amount.text),tempType);
                    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
                  },
                  child: const Text("Submit",style: TextStyle(color: Colors.white),)
              )
            ],
          );
        });
  }
  createTransaction(String shopId,String shopName,String narration,num amount,String type) async{
    String transactionId=DateTime.now().microsecondsSinceEpoch.toString();
    await AccountDb(companyId: widget.companyModel.companyId, transactionId: transactionId).saveTransaction(
        AccountModel.toJson(
            transactionId: transactionId,
            transactionBy: widget.userModel.userId,
            desc: shopName,
            narration: narration,
            amount: amount,
            type: type,
            dateTime: DateTime.now().toString()
        )
    ).then((value)async{
      if(value==true){
        await ShopDB(companyId: widget.companyModel.companyId, shopId: shopId).updateWallet(-amount).then((value)async{
          updateOrderStatus("deliver".toUpperCase());
        }).then((value)async{
          await UserDb(id: widget.userModel.userId).updateWalletBalance(amount);
        }).onError((error, stackTrace){
          Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
        });
      }
    }).onError((error, stackTrace) {
      Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}
