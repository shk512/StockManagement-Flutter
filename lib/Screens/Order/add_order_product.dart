import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/product_db.dart';
import 'package:stock_management/Services/DB/shop_db.dart';

import '../../Models/order_model.dart';
import '../../Models/product_model.dart';
import '../../Services/DB/report_db.dart';
import '../../utils/snack_bar.dart';

class OrderProduct extends StatefulWidget {
  final CompanyModel companyModel;
  final OrderModel orderModel;
  final shopId;
  const OrderProduct({Key? key,required this.orderModel,required this.companyModel,required this.shopId}) : super(key: key);

  @override
  State<OrderProduct> createState() => _OrderProductState();
}

class _OrderProductState extends State<OrderProduct> {
  Stream? products;

  @override
  void initState() {
    super.initState();
    getProducts();
  }
  getProducts()async{
    await ProductDb(companyId: widget.companyModel.companyId, productId: "").getProducts().then((value){
      setState(() {
        products=value;
      });
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),))));
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
      ),
      body: StreamBuilder(
        stream: products,
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if(snapshot.hasError){
            return const Center(child: Text("Error"),);
          }
          if(!snapshot.hasData){
            return const Center(child: Text("No Data Found"),);
          }else{
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context,index){
              if(snapshot.data.docs[index]["isDeleted"]==true){
                return const SizedBox(height: 0,);
              }else{
                return ListTile(
                  onTap: (){
                    showOrderDialogue(snapshot.data.docs[index]);
                  },
                  title: Text("${snapshot.data.docs[index]["productName"]}"),
                  subtitle: Text("${snapshot.data.docs[index]["description"]}"),
                  trailing: Text("${snapshot.data.docs[index]["totalPrice"]} Rs."),
                );
              }
            });
          }
        },
      ),
    );
  }
  showOrderDialogue(DocumentSnapshot snapshot){
    final formKey=GlobalKey<FormState>();
    num price=0;
    num quantity=0;
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(snapshot["productName"]),
            content: Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text("Quantity per piece: ${snapshot["quantityPerPiece"]}")
                        ),
                        const SizedBox(width: 5,),
                        const Expanded(flex:1,child: Text("X")),
                        Expanded(
                            flex: 1,
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Piece",
                                  hintText: "1"
                              ),
                              onChanged: (val){
                                quantity=val.isEmpty?0:int.parse(val);
                              },
                              validator: (val){
                                return int.parse(quantity.toString())==0?"Invalid":null;
                              },
                            )
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: "Price",
                          hintText: "${snapshot["totalPrice"]}"
                      ),
                      onChanged: (val){
                        price=val.isEmpty?0:int.parse(val);
                      },
                      validator: (val){
                        return int.parse(val.toString())<int.parse(snapshot["minPrice"].toString())?"Invalid":null;
                      },
                    ),
                  ],
                )
            ),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel",style: TextStyle(color: Colors.white))),
              ElevatedButton(
                  onPressed: ()async{
                    if(formKey.currentState!.validate()){
                      num totalPrice=quantity*price;
                      ProductModel productModel=ProductModel();
                      productModel.imageUrl=snapshot["imageUrl"];
                      productModel.productId=snapshot["productId"];
                      productModel.productName= snapshot["productName"];
                      productModel.description= snapshot["description"];
                      productModel.isDeleted= false;
                      productModel.totalPrice= totalPrice;
                      productModel.minPrice= price;
                      productModel.quantityPerPiece= snapshot["quantityPerPiece"];
                      productModel.totalQuantity= int.parse(quantity.toString());
                      widget.orderModel.products.add(productModel.toJson());
                      await ProductDb(companyId: widget.companyModel.companyId, productId: snapshot["productId"]).decrement(quantity).then((value)async{
                        String formattedDate=DateFormat("yyyy-MM-dd").format(DateTime.now());
                        await ReportDb(companyId: widget.companyModel.companyId, productId: snapshot["productId"]).increment(quantity, formattedDate).then((value)async{
                          await ShopDB(companyId: widget.companyModel.companyId, shopId: widget.shopId).updateWallet(totalPrice).then((value){
                            Navigator.pop(context);
                            showSnackbar(context, Colors.green.shade300, "Added");
                            setState(() {
                              widget.orderModel.totalAmount+=totalPrice;
                            });
                          });
                        });
                      });
                    }
                  },
                  child: const Text("Add to Cart",style: TextStyle(color: Colors.white),)),
            ],
          );
        });
  }
}
