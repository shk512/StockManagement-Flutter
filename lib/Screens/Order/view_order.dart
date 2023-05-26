
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/open_map.dart';
import 'package:stock_management/Functions/pdf_api.dart';
import 'package:stock_management/Functions/pdf_build.dart';
import 'package:stock_management/Models/order_model.dart';
import 'package:stock_management/Screens/Order/deliver_form.dart';
import 'package:stock_management/Screens/Order/edit_order.dart';
import 'package:stock_management/Screens/Order/deliver_man.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/order_db.dart';
import 'package:stock_management/Services/DB/shop_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/Widgets/row_info_display.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Constants/rights.dart';
import '../../Models/company_model.dart';
import '../../Models/user_model.dart';

class ViewOrder extends StatefulWidget {
  final String orderId;
  final CompanyModel companyModel;
  final UserModel userModel;
  const ViewOrder({Key? key,required this.orderId,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  OrderModel orderModel=OrderModel();
  DocumentSnapshot? shopSnapshot;
  String orderBookerName = "";
  String deliveryManName = "";
  GeoPoint shopLocation = GeoPoint(0, 0);
  bool isLoading=false;


  @override
  void initState() {
    super.initState();
    getOrderData();
  }
  @override
  void dispose(){
    super.dispose();
  }
  getOrderData() async {
    await OrderDB(
        companyId: widget.companyModel.companyId, orderId: widget.orderId)
        .getOrderById()
        .then((value) async {
      setState(() {
        orderModel.fromJson(value);
      });
      await ShopDB(
          companyId: widget.companyModel.companyId, shopId: value["shopId"])
          .getShopDetails()
          .then((value) async {
        setState(() {
          shopSnapshot = value;
          shopLocation = value["geoLocation"];
        });
      }).onError((error, stackTrace) => Navigator.push(context,
          MaterialPageRoute(
              builder: (context) => ErrorScreen(error: error.toString(),key: Key("errorScreen"),))));
      await UserDb(id: value["orderBy"]).getData().then((value) {
        setState(() {
          orderBookerName = "${value["name"]}\t${value["phone"]}";
        });
      });
      if (value["deliverBy"]
          .toString()
          .isNotEmpty) {
        await UserDb(id: value["deliverBy"]).getData().then((value) {
          setState(() {
            deliveryManName = "${value["name"]}\t${value["phone"]}";
          });
        });
      }

    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(
        builder: (context) => ErrorScreen(error: error.toString(),key: Key("errorScreen"),))));
  }


  @override
  Widget build(BuildContext context) {
    if (orderModel.products.isEmpty || shopSnapshot==null) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator(),),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(CupertinoIcons.back, color: Colors.white,),
          ),
          title: const Text("Invoice", style: TextStyle(color: Colors.white),),
          actions: [
            IconButton(
                onPressed: () async{
                  setState(() {
                    isLoading=true;
                  });
                  if(orderModel.products.isNotEmpty && shopSnapshot!=null){
                    await BuildPdf.generate(
                        companyName: widget.companyModel.companyName,
                        invoiceNo: widget.orderId,
                        products: orderModel.products,
                        totalAmount: orderModel.totalAmount.toString(),
                        balanceAmount: orderModel.balanceAmount.toString(),
                        advanceAmount: orderModel.advanceAmount.toString(),
                        concessionAmount: orderModel.concessionAmount.toString(),
                        shopName: orderModel.shopDetails,
                        contactPerson: "${shopSnapshot!["ownerName"]}\t${shopSnapshot!["contact"]}").then((file){
                      PdfApi.openFile(file);
                      setState(() {
                        isLoading=false;
                      });
                    });
                  }
                }, icon: Icon(Icons.download, color: Colors.white,)),
            orderModel.status == "Deliver".toUpperCase()
                ? const SizedBox()
                : PopupMenuButton(
                color: Colors.white,
                onSelected: (value) async{
                  if (value == 0 &&
                      (widget.userModel.rights.contains(Rights.editOrder) ||
                          widget.userModel.rights.contains(Rights.all))) {
                    await Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            EditOrder(companyModel: widget.companyModel,key: Key("editOrder"), orderModel: orderModel,)));
                    setState(() {
                      getOrderData();
                    });
                  }
                  if (value == 1 && (widget.userModel.rights.contains(
                      Rights.shopNavigation) ||
                      widget.userModel.rights.contains(Rights.all))) {
                    try {
                      openMap(shopLocation.latitude, shopLocation.longitude);
                    } catch (e) {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              ErrorScreen(error: e.toString(),key: Key("errorScreen"),)));
                    }
                  }
                  if (value == 2 && (widget.userModel.rights.contains(
                      Rights.orderNavigation) ||
                      widget.userModel.rights.contains(Rights.all))) {
                    try {
                      openMap(shopLocation.latitude, shopLocation.longitude);
                    } catch (e) {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              ErrorScreen(error: e.toString(),key: Key("errorScreen"),)));
                    }
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: 0,
                      child: Row(children: const [
                        Icon(Icons.edit, color: Colors.black54,),
                        SizedBox(width: 5,),
                        Text("Edit")
                      ],),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Row(children: const [
                        Icon(Icons.navigation, color: Colors.black54,),
                        SizedBox(width: 5,),
                        Text("Shop")
                      ],),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Row(children: const [
                        Icon(Icons.navigation, color: Colors.black54,),
                        SizedBox(width: 5,),
                        Text("Order")
                      ],),
                    ),
                  ];
                }
            ),
          ],
        ),
        floatingActionButton: orderModel.status ==
            "processing".toUpperCase()
            ? FloatingActionButton.extended(
          onPressed: () {
            if (widget.userModel.rights.contains(Rights.dispatchOrder) ||
                widget.userModel.rights.contains(Rights.all)) {
              updateOrderStatus();
            }
          },
          label: const Text("Dispatch", style: TextStyle(color: Colors.white),),
        )
            : orderModel.status == "dispatch".toUpperCase()
            ? FloatingActionButton.extended(
          onPressed: () {
            if (widget.userModel.rights.contains(Rights.deliverOrder) ||
                widget.userModel.rights.contains(Rights.all)) {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  DeliverForm(companyModel: widget.companyModel,
                    userModel: widget.userModel, key: Key("deliverForm"), orderModel: orderModel,)));
            }
          },
          label: const Text("Deliver", style: TextStyle(color: Colors.white),),
        )
            : const SizedBox(),
        body: orderBookerName.isEmpty || isLoading
            ? const Center(child: CircularProgressIndicator(),)
            : Column(
          children: [
             Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    RowInfoDisplay(value: orderModel.orderId, label: "Invoice#"),
                    RowInfoDisplay(value: orderModel.shopDetails,
                        label: "Shop Details"),
                    RowInfoDisplay(
                        value: orderModel.dateTime, label: "Order Date"),
                    RowInfoDisplay(
                        value: orderModel.remarks, label: "Remarks"),
                    RowInfoDisplay(
                        value: orderModel.totalAmount.toString(),
                        label: "Total Amount"),
                    RowInfoDisplay(
                        value: orderModel.advanceAmount.toString(),
                        label: "Receive Amount"),
                    RowInfoDisplay(
                        value: orderModel.concessionAmount.toString(),
                        label: "Concession Amount"),
                    RowInfoDisplay(
                        value: orderModel.balanceAmount.toString(),
                        label: "Balance Amount"),
                    RowInfoDisplay(value: orderBookerName, label: "Order By"),
                    RowInfoDisplay(value: deliveryManName, label: "Deliver By"),
                  ],
                ),
              ),
            const SizedBox(height: 5,),
            Expanded(
              child: ListView.builder(
                  itemCount: orderModel.products.length,
                  itemBuilder: (context, index) {
                    if (orderModel.products.isEmpty) {
                      return const Center(child: Text("Cart is Empty"),);
                    } else {
                      return ListTile(
                          title: Text("${orderModel
                              .products[index]["productName"]}-${orderModel
                              .products[index]["description"]}"),
                          subtitle: Text("Detail: ${orderModel
                              .products[index]["totalQuantity"]}x${orderModel
                              .products[index]["minPrice"]}=${orderModel
                              .products[index]["totalPrice"]}"),
                          trailing: ClipOval(
                              child: SizedBox(
                                height: 30,
                                width: 30,
                                child: Material(
                                  color: Colors.brown,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${orderModel
                                          .products[index]["totalQuantity"]}",
                                      style: TextStyle(fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white),),
                                  ),
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
  updateOrderStatus()async{
    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderId).updateOrder({
      "status": "Dispatch".toUpperCase()
    }).then((value){
      if(value==true){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>EditUserId(orderId: widget.orderId, companyModel: widget.companyModel,userModel: widget.userModel,)));
      }else{
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}
