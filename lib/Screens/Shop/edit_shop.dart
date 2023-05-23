import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/shop_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Models/user_model.dart';
import '../../Widgets/num_field.dart';
import '../../Widgets/text_field.dart';

class EditShop extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  final String shopId;
  const EditShop({Key? key,required this.shopId,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<EditShop> createState() => _EditShopState();
}

class _EditShopState extends State<EditShop> {
  TextEditingController shopName=TextEditingController();
  TextEditingController ownerName=TextEditingController();
  TextEditingController contact=TextEditingController();
  TextEditingController nearBy=TextEditingController();
  String areaName="";
  final formKey=GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getShopDetails();
  }
  getShopDetails()async{
    await ShopDB(companyId: widget.companyModel.companyId,shopId: widget.shopId).getShopDetails().then((value){
      setState(() {
        shopName.text=value["shopName"];
        ownerName.text=value["ownerName"];
        contact.text=value["contact"];
        nearBy.text=value["nearBy"];
        areaName=value["areaId"];
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
            }, icon: Icon(CupertinoIcons.back,color: Colors.white,)
        ),
        title: Text(areaName,style: const TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: (){
                showWarningDialogue(widget.shopId);
              },
              icon: const Icon(Icons.delete,color: Colors.white,))
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          if(formKey.currentState!.validate()){
            updateShop();
          }
        },
        label: const Text("Update",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
      ),
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
  updateShop()async{
    await ShopDB(companyId: widget.companyModel.companyId, shopId: widget.shopId).updateShop({
      "shopName":shopName.text,
      "ownerName":ownerName.text,
      "contact":contact.text,
      "nearBy":nearBy.text,
    }).then((value){
      if(value==true){
        showSnackbar(context, Colors.green.shade300, "Updated");
        Navigator.pop(context);
      }else{
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  deleteShop(String shopId)async{
    await ShopDB(companyId: widget.companyModel.companyId, shopId: shopId).deleteShop().then((value) {
      if(value==true){
        showSnackbar(context, Colors.green.shade300, "Deleted");
        Navigator.pop(context);
      }else{
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  showWarningDialogue(String shopId){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Warning"),
            content: const Text("Are you sure to delete this shop?"),
            actions: [
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel,color: Colors.red,)),
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                    deleteShop(shopId);
                  },
                  icon: const Icon(Icons.check_circle_rounded,color: Colors.green,)),
            ],
          );
        }
    );
  }
}
