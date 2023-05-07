import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Screens/Shop/add_shop.dart';

import '../../Functions/get_data.dart';
import '../../Models/company_model.dart';
import '../../Models/user_model.dart';
import '../../Services/DB/shop_db.dart';
import '../Order/order_form.dart';
import 'edit_shop.dart';

class AreaShop extends StatefulWidget {
  final String areaName;
  const AreaShop({Key? key,required this.areaName}) : super(key: key);

  @override
  State<AreaShop> createState() => _AreaShopState();
}

class _AreaShopState extends State<AreaShop> {
  Stream? shops;
  String address='';
  String tab="all".toUpperCase();
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
      floatingActionButton: UserModel.rights.contains("addshop".toLowerCase())
          ?FloatingActionButton.extended(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>AddShop(areaName: widget.areaName)));
          },
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("Shop",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
      )
        :const SizedBox(),
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
                      itemBuilder: (context,index) {
                          if(snapshot.data.docs[index]["areaId"]==widget.areaName && snapshot.data.docs[index]["isDeleted"]==false){
                            return ListTile(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderForm(shopId: snapshot.data.docs[index]["shopId"])));
                              },
                              leading: Icon(Icons.brightness_1,size: 10,color: snapshot.data.docs[index]["isActive"]?Colors.green:Colors.red,),
                              title: Text("${snapshot.data.docs[index]["shopName"]}"),
                              subtitle: Text("${snapshot.data.docs[index]["ownerName"]}\t${snapshot.data.docs[index]["contact"]}"),
                            );
                        }else{
                            return const SizedBox(height: 0,);
                          }
                          },
                  );
                }
              }
    )
    );
  }
}
