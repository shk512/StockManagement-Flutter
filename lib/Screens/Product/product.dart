import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/get_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/product_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Product/edit_product.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/product_db.dart';
import 'package:stock_management/Widgets/floating_action_button.dart';

import '../../utils/routes.dart';
import '../../utils/snack_bar.dart';

class Product extends StatefulWidget {
  const Product({Key? key}) : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  Stream? products;
  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid);
    getProducts();
  }
  getProducts()async{
    await ProductDb(companyId: CompanyModel.companyId, productId: "").getProducts().then((value){
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
      floatingActionButton:const FloatingActionBtn(route: Routes.addProduct, name: "Product"),
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
                      return SizedBox(height: 0,);
                    }else{
                      return ListTile(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProduct(productId: snapshot.data.docs[index]["productId"])));
                        },
                        title: Text(snapshot.data.docs[index]["productName"]),
                        subtitle: Text("Price: ${snapshot.data.docs[index]["totalPrice"]} Rs."),
                        trailing: UserModel.role=="manager".toUpperCase()
                            ?InkWell(
                            onTap:(){
                              showWarning(snapshot.data.docs[index]["productId"]);
                            },
                            child: Icon(Icons.delete,color: Colors.red,))
                            :SizedBox(height: 0,),
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
    await ProductDb(companyId: CompanyModel.companyId, productId: productId).deleteProduct().then((value){
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
