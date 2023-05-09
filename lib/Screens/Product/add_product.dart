import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/product_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Services/DB/product_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Widgets/num_field.dart';
import '../../Widgets/text_field.dart';
import '../Splash_Error/error.dart';

class AddProduct extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const AddProduct({Key? key,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController productName=TextEditingController();
  TextEditingController description=TextEditingController();
  TextEditingController totalPrice=TextEditingController();
  TextEditingController minPrice=TextEditingController();
  TextEditingController quantityPerPiece=TextEditingController();
  String imageUrl="";
  final formKey=GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
        title: const Text("New Product",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(formKey.currentState!.validate()){
            saveProduct();
          }
        },
        child: const Text("Save",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              child: Column(
                children: [
                  TxtField(labelTxt: "Product Name", hintTxt: "Enter the product name", ctrl: productName, icon: const Icon(Icons.add)),
                  const SizedBox(height: 10,),
                  TxtField(labelTxt: "Description", hintTxt: "Product description", ctrl: description, icon: const Icon(Icons.description)),
                  const SizedBox(height: 10,),
                  NumField(labelTxt: "Retail price", hintTxt: "Retail price of product", ctrl: totalPrice, icon: const Icon(Icons.currency_ruble_outlined)),
                  const SizedBox(height: 10,),
                  NumField(labelTxt: "Min price", hintTxt: "Minimum price of product", ctrl: minPrice, icon: const Icon(Icons.currency_ruble_outlined)),
                  const SizedBox(height: 10,),
                  NumField(labelTxt: "Quantity", hintTxt: "Quantity per piece", ctrl: quantityPerPiece, icon: const Icon(Icons.production_quantity_limits)),
                ],
              ),
            )
        ),
      ),
    );
  }
  saveProduct()async{
    String productId=DateTime.now().microsecondsSinceEpoch.toString();
    await ProductDb(companyId: widget.companyModel.companyId, productId: productId).saveProduct(ProductModel.toJson(
        imageUrl: imageUrl,
        productId: productId,
        productName: productName.text,
        description: description.text,
        isDeleted: false,
        totalPrice: int.parse(totalPrice.text),
        minPrice: int.parse(minPrice.text),
        quantityPerPiece: int.parse(quantityPerPiece.text),
        totalQuantity: 0)
    ).then((value){
      if(value==true){
        Navigator.pop(context);
        showSnackbar(context, Colors.cyan, "Saved");
      }else{
        showSnackbar(context, Colors.red, "Error");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),)));
    });
  }
}
