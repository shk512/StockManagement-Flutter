import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/get_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/shop_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Order/order_form.dart';
import 'package:stock_management/Screens/Shop/add_shop.dart';
import 'package:stock_management/Screens/Shop/edit_shop.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/shop_db.dart';
import 'package:stock_management/Widgets/row_info_display.dart';
import 'package:stock_management/utils/snack_bar.dart';

class Shop extends StatefulWidget {
  final String areaName;
  const Shop({Key? key,required this.areaName}) : super(key: key);

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  Stream? shops;
  String address='';
  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid);
    getShops();
  }
  getShops()async{
    var request=await ShopDB(companyId: CompanyModel.companyId, shopId: "").getShops();
      setState(() {
        shops=request;
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
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>AddShop(areaName: widget.areaName)));
          },
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("Shop",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
      ),
      body: StreamBuilder(
        stream: shops,
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
                  if(snapshot.data.docs[index]["areaId"]==widget.areaName && snapshot.data.docs[index]["isDeleted"]==false){
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      child: displayCard(snapshot.data.docs[index]),
                    );
                  }else{
                    return const SizedBox(height: 0,);
                  }
                }
            );
          }
        },
      ),
    );
  }
  displayCard(var snapshot){
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderForm(shopId: snapshot["shopId"])));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(snapshot["shopName"],style: const TextStyle(fontWeight: FontWeight.bold),)),
                  UserModel.role=="Manager".toUpperCase()
                      ? Expanded(
                      child: Row(
                        children: [
                          Expanded(child: IconButton(
                            icon: const Icon(Icons.delete,color: Colors.red,),
                            onPressed: () {
                              showWarningDialogue(snapshot["shopId"]);
                            },
                          ) ,),
                          Expanded(child: IconButton(
                            icon: const Icon(Icons.edit,color: Colors.black38),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>EditShop(shopId: snapshot["shopId"])));
                            },
                          ),),
                        ]))
                      :const SizedBox(height: 0,),
                ],),
              const SizedBox(height: 5,),
              RowInfoDisplay(label: "Person Name", value:snapshot["ownerName"]),
              const SizedBox(height: 5,),
              RowInfoDisplay(label: "Contact", value: snapshot["contact"]),
              const SizedBox(height: 5,),
            ],
          ),
        ),
      ),
    );
  }
  deleteShop(String shopId)async{
    await ShopDB(companyId: CompanyModel.companyId, shopId: shopId).deleteShop().then((value) {
      if(value==true){
        showSnackbar(context, Colors.cyan, "Deleted");
        setState(() {

        });
      }else{
        showSnackbar(context, Colors.cyan, "Error");
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