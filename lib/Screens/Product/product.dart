import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Product/add_product.dart';
import 'package:stock_management/Screens/Product/edit_product.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/product_db.dart';

import '../../utils/snack_bar.dart';

class Product extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const Product({Key? key,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  Stream? products;
  CompanyModel _companyModel=CompanyModel();
  UserModel _userModel=UserModel();
  @override
  void initState() {
    super.initState();
    getProducts();
  }
  getProducts()async{
    await ProductDb(companyId: _companyModel.companyId, productId: "").getProducts().then((value){
      setState(() {
        products=value;
      });
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
        title: const Text("Product",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context)=>AddProduct(userModel: widget.userModel, companyModel: widget.companyModel)));
          },
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("Product",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
      ),
      body:  StreamBuilder(
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
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProduct(productId: snapshot.data.docs[index]["productId"], userModel: widget.userModel, companyModel: widget.companyModel,)));
                        },
                        title: Text(snapshot.data.docs[index]["productName"]),
                        subtitle: Text("Price: ${snapshot.data.docs[index]["totalPrice"]} Rs."),
                        trailing: _userModel.role=="manager".toUpperCase()
                            ?InkWell(
                            onTap:(){
                              showWarning(snapshot.data.docs[index]["productId"]);
                            },
                            child: const Icon(Icons.delete,color: Colors.red,))
                            :const SizedBox(height: 0,),
                      );
                    }
                  });
          }}),
    );
  }
  showWarning(String productId){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Warning"),
            content: const Text("Are you sure to delete this product?"),
            actions: [
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel,color: Colors.red,)),
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                    deleteProduct(productId);
                  },
                  icon: const Icon(Icons.check_circle_rounded,color: Colors.green,)),
            ],
          );
        }
    );
  }
  deleteProduct(String productId)async{
    await ProductDb(companyId: _companyModel.companyId, productId: productId).deleteProduct().then((value){
      if(value==true){
        showSnackbar(context,Colors.cyan,"Deleted");
      }else{
        showSnackbar(context, Colors.red, "Error");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}
