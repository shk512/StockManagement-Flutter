import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stock_management/Models/product_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Order/cart.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/product_db.dart';
import 'package:stock_management/Services/DB/report_db.dart';
import 'package:stock_management/Services/DB/shop_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Models/company_model.dart';
import '../../Models/order_model.dart';

class OrderForm extends StatefulWidget {
  final String shopId;
  final CompanyModel companyModel;
  final UserModel userModel;
  const OrderForm({Key? key,required this.shopId,required this.companyModel,required this.userModel}) : super(key: key);

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  String shopName="";
  String shopDetails="";
  Stream? products;

  @override
  void initState() {
    super.initState();
    getProducts();
    getShopDetails();
  }
  getShopDetails()async{
    await ShopDB(companyId: widget.companyModel.companyId, shopId: widget.shopId).getShopDetails().then((value){
      setState(() {
        shopName=value["shopName"];
        shopDetails="${value["shopName"]},\t near ${value["nearBy"]},\t ${value["areaId"]}";
      });
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  getProducts()async{
    await ProductDb(companyId: widget.companyModel.companyId, productId: "").getProducts().then((value) {
      setState(() {
        products=value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: Text(shopName,style: const TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: <Widget>[

           Padding(padding: const EdgeInsets.all(10.0),

            child: SizedBox(
                height: 150.0,
                width: 30.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,MaterialPageRoute(builder: (context)=>Cart(shopId: widget.shopId,shopDetails: shopDetails, userModel: widget.userModel,companyModel: widget.companyModel,)));
                  },

                  child: Stack(

                    children: <Widget>[
                      const IconButton(icon: Icon(Icons.shopping_cart,
                        color: Colors.white,),
                        onPressed: null,
                      ),
                      OrderModel.products.isEmpty?Container() :
                      Positioned(

                          child: Stack(
                            children: <Widget>[
                              const Icon(
                                  Icons.brightness_1,
                                  size: 20.0, color: Colors.yellow),
                              Positioned(
                                  top: 3.0,
                                  right: 4.0,
                                  child: Center(
                                    child: Text(
                                      OrderModel.products.length.toString(),
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  )),


                            ],
                          )),

                    ],
                  ),
                )
            )

            ,)],
      ),
      body: StreamBuilder(
          stream: products,
          builder: (context,AsyncSnapshot snapshot){
            if(snapshot.connectionState==ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(),);
            }
            if(snapshot.hasError){
              return const Center(child: Text("error"),);
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
                     OrderModel.products.add(ProductModel.toJson(
                          imageUrl: snapshot["imageUrl"],
                          productId: snapshot["productId"],
                          productName: snapshot["productName"],
                          description: snapshot["description"],
                          isDeleted: false,
                          totalPrice: totalPrice,
                          minPrice: price,
                          quantityPerPiece: snapshot["quantityPerPiece"],
                          totalQuantity: int.parse(quantity.toString())
                      )
                     );
                     await ProductDb(companyId: widget.companyModel.companyId, productId: snapshot["productId"]).decrement(quantity).then((value)async{
                       String formattedDate=DateFormat("yyyy-MM-dd").format(DateTime.now());
                       await ReportDb(companyId: widget.companyModel.companyId, productId: snapshot["productId"]).increment(quantity, formattedDate).then((value){
                         Navigator.pop(context);
                         showSnackbar(context, Colors.cyan, "Added to cart");
                         setState(() {
                           OrderModel.totalAmount+=totalPrice;
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