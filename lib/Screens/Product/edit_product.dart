import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Services/DB/product_db.dart';

import '../../Functions/image_upload.dart';
import '../../Models/user_model.dart';
import '../../Widgets/num_field.dart';
import '../../Widgets/text_field.dart';
import '../../utils/snack_bar.dart';
import '../Splash_Error/error.dart';

class EditProduct extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  final String productId;
  const EditProduct({Key? key,required this.productId,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
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
    getProductDetails();
  }
  getProductDetails()async{
    await ProductDb(companyId: widget.companyModel.companyId, productId: widget.productId).getProductDetails().then((value){
      setState(() {
        productName.text=value["productName"];
        description.text=value["description"];
        totalPrice.text=value["totalPrice"].toString();
        minPrice.text=value["minPrice"].toString();
        quantityPerPiece.text=value["quantityPerPiece"].toString();
        imageUrl=value["imageUrl"];
      });
    });
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
        title: const Text("Edit Product",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          ElevatedButton(
              onPressed: (){
                if(formKey.currentState!.validate()){
                  updateProduct();
                }
              }, child: Text("Update"))
        ],
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
                  const SizedBox(height: 10,),
                  InkWell(
                    onTap: (){
                      try{
                        uploadImage().then((value){
                          setState(() {
                            imageUrl=value;
                          });
                        });
                      }catch (e){
                        showSnackbar(context, Colors.red.shade400, e.toString());
                      }
                    },
                    child: Container(
                      color: Colors.brown.shade200,
                      alignment: Alignment.center,
                      height: 200,
                      width: 200,
                      child: imageUrl.isEmpty
                          ?Icon(Icons.image,size: 100,)
                          : Image.network(imageUrl),
                    ),
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
  updateProduct()async{
    await ProductDb(companyId: widget.companyModel.companyId, productId: widget.productId).updateProduct({
      "productName":productName.text,
      "description":description.text,
      "totalPrice":int.parse(totalPrice.text),
      "minPrice":int.parse(minPrice.text),
      "quantityPerPiece":int.parse(quantityPerPiece.text),
      "imageUrl":imageUrl
    }).then((value){
      if(value==true){
        showSnackbar(context, Colors.green.shade300, "Updated");
        Navigator.pop(context);
      }else{
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(), key: Key("errorScreen"),)));
    });
  }
}
