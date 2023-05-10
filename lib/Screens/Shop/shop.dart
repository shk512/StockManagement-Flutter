import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Shop/edit_shop.dart';
import 'package:stock_management/Services/DB/shop_db.dart';

import '../../Constants/rights.dart';
import '../../utils/snack_bar.dart';
import '../Splash_Error/error.dart';

class Shop extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const Shop({Key? key,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  Stream? shops;
  String address='';
  String tab="all".toUpperCase();

  @override
  void initState() {
    super.initState();
    getShops();
  }
  getShops()async{
    var request=await ShopDB(companyId: widget.companyModel.companyId, shopId: "").getShops();
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
        title: const Text("Shop",style: const TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*
          *
          * TAB
          *
          * */
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            child: SizedBox(
              height: 25,
              child: Row(
                children: [
                  //All
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          tab="all".toUpperCase();
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(18),bottomLeft: Radius.circular(18)),
                          color: tab=="all".toUpperCase()?Colors.black38:Colors.cyan.withOpacity(0.8),
                        ),
                        child:const Text("All",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                  //active
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          tab="active".toUpperCase();
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: tab=="active".toUpperCase()?Colors.green:Colors.cyan.withOpacity(0.8)
                        ),
                        child: const Text("Active",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  //in active
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          tab="Inactive".toUpperCase();
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: tab=="inactive".toUpperCase()?Colors.red:Colors.cyan.withOpacity(0.8),
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(18),bottomRight: Radius.circular(18)),
                        ),
                        child: const Text("In-Active",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          /*
          *
          * STREAM
          *
          * */
          Expanded(
            child: StreamBuilder(
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
                      itemBuilder: (context,index) {
                        if(tab=="all".toUpperCase()){
                          return listTile(snapshot.data.docs[index]);
                        }else if(tab=="Active".toUpperCase() && snapshot.data.docs[index]["isActive"]==true){
                          return listTile(snapshot.data.docs[index]);
                        }else if(tab=="InActive".toUpperCase() && snapshot.data.docs[index]["isActive"]==false){
                          return listTile(snapshot.data.docs[index]);
                        }else{
                          return const SizedBox(height: 0,);
                        }
                      });
                }
              },
            ),),
        ],
      ),
    );
  }
  listTile(DocumentSnapshot snapshot){
    return ListTile(
      onTap: (){
        if(widget.userModel.rights.contains(Rights.editShop)||widget.userModel.rights.contains(Rights.all)){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>EditShop(shopId: snapshot["shopId"], userModel: widget.userModel, companyModel: widget.companyModel,)));
        }
      },
      leading: tab=="all".toUpperCase()?Icon(Icons.brightness_1,size: 10,color: snapshot["isActive"]?Colors.green:Colors.red,):const SizedBox(),
      title: Text("${snapshot["shopName"]}-${snapshot["areaId"]}"),
      subtitle: Text("${snapshot["ownerName"]}\t${snapshot["contact"]}"),
      isThreeLine: true,
      trailing: widget.userModel.rights.contains(Rights.changeShopStatus)|| widget.userModel.rights.contains(Rights.all)
          ?  ElevatedButton(
        child: Text(snapshot["isActive"]?"Inactive":"Active",style: const TextStyle(color: Colors.white),),
        onPressed: () {
          updateStatus(snapshot);
        },
      )
          :const SizedBox(height: 0,),
    );
  }
  updateStatus(DocumentSnapshot snapshot)async{
    await ShopDB(companyId: widget.companyModel.companyId, shopId: snapshot["shopId"]).updateShop({
      "shopName":snapshot["shopName"],
      "ownerName":snapshot["ownerName"],
      "contact":snapshot["contact"],
      "nearBy":snapshot["nearBy"],
      "isActive":!snapshot["isActive"]
    }).then((value){
      if(value==true){
        showSnackbar(context, Colors.cyan, "Updated");
      }else{
        showSnackbar(context, Colors.red, "Error");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}
