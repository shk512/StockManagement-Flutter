
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
  DocumentSnapshot? orderSnapshot;
  DocumentSnapshot? shopSnapshot;
  String orderBookerName = "";
  String deliveryManName = "";
  GeoPoint orderLocation = GeoPoint(0, 0);
  GeoPoint shopLocation = GeoPoint(0, 0);
  bool isLoading=false;


  @override
  void initState() {
    super.initState();
    getOrderData();
  }
  @override
  void dispose(){
    OrderModel.products=[];
    OrderModel.totalAmount=0;
    super.dispose();
  }
  getOrderData() async {
    await OrderDB(
        companyId: widget.companyModel.companyId, orderId: widget.orderId)
        .getOrderById()
        .then((value) async {
      setState(() {
        orderSnapshot = value;
        OrderModel.products = List.from(value["products"]);
        OrderModel.totalAmount = value["totalAmount"];
        orderLocation = value["geoLocation"];
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
    if (orderSnapshot == null || shopSnapshot==null) {
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
                  if(orderSnapshot!=null && shopSnapshot!=null){
                    await BuildPdf.generate(
                        companyName: widget.companyModel.companyName,
                        invoiceNo: widget.orderId,
                        products: OrderModel.products,
                        totalAmount: orderSnapshot!["totalAmount"].toString(),
                        balanceAmount: orderSnapshot!["balanceAmount"].toString(),
                        advanceAmount: orderSnapshot!["advanceAmount"].toString(),
                        concessionAmount: orderSnapshot!["concessionAmount"].toString(),
                        shopName: orderSnapshot!["shopDetails"],
                        contactPerson: "${shopSnapshot!["ownerName"]}\t${shopSnapshot!["contact"]}").then((file){
                      PdfApi.openFile(file);
                      setState(() {
                        isLoading=false;
                      });
                    });
                  }
                }, icon: Icon(Icons.download, color: Colors.white,)),
            orderSnapshot!["status"] == "Deliver".toUpperCase()
                ? const SizedBox()
                : PopupMenuButton(
                color: Colors.white,
                onSelected: (value) {
                  if (value == 0 &&
                      (widget.userModel.rights.contains(Rights.editOrder) ||
                          widget.userModel.rights.contains(Rights.all))) {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) =>
                            EditOrder(orderId: widget.orderId,
                                companyModel: widget.companyModel,key: Key("editOrder"),)));
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
        floatingActionButton: orderSnapshot!["status"] ==
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
            : orderSnapshot!["status"] == "dispatch".toUpperCase()
            ? FloatingActionButton.extended(
          onPressed: () {
            if (widget.userModel.rights.contains(Rights.deliverOrder) ||
                widget.userModel.rights.contains(Rights.all)) {
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  DeliverForm(companyModel: widget.companyModel,
                    userModel: widget.userModel,
                    orderId: widget.orderId,key: Key("deliverForm"),)));
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
                    RowInfoDisplay(value: orderSnapshot!["orderId"], label: "Invoice#"),
                    RowInfoDisplay(value: orderSnapshot!["shopDetails"],
                        label: "Shop Details"),
                    RowInfoDisplay(
                        value: orderSnapshot!["dateTime"], label: "Order Date"),
                    RowInfoDisplay(
                        value: orderSnapshot!["remarks"], label: "Remarks"),
                    RowInfoDisplay(
                        value: orderSnapshot!["totalAmount"].toString(),
                        label: "Total Amount"),
                    RowInfoDisplay(
                        value: orderSnapshot!["advanceAmount"].toString(),
                        label: "Receive Amount"),
                    RowInfoDisplay(
                        value: orderSnapshot!["concessionAmount"].toString(),
                        label: "Concession Amount"),
                    RowInfoDisplay(
                        value: orderSnapshot!["balanceAmount"].toString(),
                        label: "Balance Amount"),
                    RowInfoDisplay(value: orderBookerName, label: "Order By"),
                    RowInfoDisplay(value: deliveryManName, label: "Deliver By"),
                  ],
                ),
              ),
            const SizedBox(height: 5,),
            Expanded(
              child: ListView.builder(
                  itemCount: OrderModel.products.length,
                  itemBuilder: (context, index) {
                    if (OrderModel.products.isEmpty) {
                      return const Center(child: Text("Cart is Empty"),);
                    } else {
                      return ListTile(
                          title: Text("${OrderModel
                              .products[index]["productName"]}-${OrderModel
                              .products[index]["description"]}"),
                          subtitle: Text("Detail: ${OrderModel
                              .products[index]["totalQuantity"]}x${OrderModel
                              .products[index]["minPrice"]}=${OrderModel
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
                                      "${OrderModel
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
        setState(() {
          OrderModel.products=[];
          OrderModel.totalAmount=0;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context)=>EditUserId(orderId: widget.orderId, companyModel: widget.companyModel,userModel: widget.userModel,)));
      }else{
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}
