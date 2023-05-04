import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/location.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/shop_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/shop_db.dart';
import 'package:stock_management/Widgets/text_field.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Widgets/num_field.dart';

class AddShop extends StatefulWidget {
  final String areaName;
  const AddShop({Key? key,required this.areaName}) : super(key: key);

  @override
  State<AddShop> createState() => _AddShopState();
}

class _AddShopState extends State<AddShop> {
  bool isLoading=false;
  double? lat;
  double? lng;
  String address='';
  TextEditingController ownerName=TextEditingController();
  TextEditingController shopName=TextEditingController();
  TextEditingController contact=TextEditingController();
  TextEditingController nearBy=TextEditingController();
  final formKey=GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getCurrentLocation(context).then((value){
      setState(() {
        lat=value.latitude;
        lng=value.longitude;
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
        title: Text(widget.areaName,style: const TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      floatingActionButton: UserModel.role=="Manager".toUpperCase() || UserModel.role=="order taker".toUpperCase()
        ?FloatingActionButton(
          onPressed: (){
            if(formKey.currentState!.validate()){
              saveShop();
            }
          },
          child: const Text("Save",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ):const SizedBox(height: 0,),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              child: Column(
                children: [
                  TxtField(labelTxt: "Shop Name", hintTxt: "Enter the shop name", ctrl: shopName, icon: const Icon(Icons.storefront_outlined)),
                  const SizedBox(height: 10,),
                  TxtField(labelTxt: "Proprietor", hintTxt: "Enter person name", ctrl: ownerName, icon: const Icon(Icons.person_outline)),
                  const SizedBox(height: 10,),
                  NumField(labelTxt: "Contact", hintTxt: "03001234567", ctrl: contact, icon: const Icon(Icons.phone)),
                  const SizedBox(height: 10,),
                  TxtField(labelTxt: "Near By", hintTxt: "Any famous nearby place", ctrl: nearBy, icon: const Icon(Icons.pin_drop_outlined))
                ],
              ),
            )
        ),
      ),
    );
  }
  saveShop()async{
    String shopId=DateTime.now().microsecondsSinceEpoch.toString();
    await ShopDB(companyId: CompanyModel.companyId, shopId: shopId).saveShop(ShopModel.toJson(
        shopId: shopId,
        areaName: widget.areaName,
        shopName: shopName.text.toUpperCase(),
        contact: contact.text,
        ownerName: ownerName.text,
        nearBy: nearBy.text,
        isDeleted: false,
        lat: lat,
        lng: lng)).then((value){
          Navigator.pop(context);
          showSnackbar(context, Colors.cyan, "Saved");
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}
