import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Screens/Shop/add_shop.dart';
import 'package:stock_management/Services/DB/area_db.dart';

import '../../Constants/rights.dart';
import '../../Models/company_model.dart';
import '../../Models/user_model.dart';
import '../../Services/DB/shop_db.dart';
import '../Order/order_form.dart';

class AreaShop extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  final String areaId;
  const AreaShop({Key? key,required this.areaId,required this.companyModel,required this.userModel}) : super(key: key);

  @override
  State<AreaShop> createState() => _AreaShopState();
}

class _AreaShopState extends State<AreaShop> {
  Stream? shops;
  DocumentSnapshot? snapshot;

  @override
  void initState() {
    super.initState();
    getShops();
    getAreaDetails();
  }
  getAreaDetails() async{
    await AreaDb(areaId: widget.areaId, companyId: widget.companyModel.companyId).getAreaById().then((value) {
      setState(() {
        snapshot=value;
      });
    });
  }
  getShops()async{
   await ShopDB(companyId: widget.companyModel.companyId, shopId: "").getShopByAreaId(widget.areaId).then((value){
     setState(() {
       shops=value;
     });
   });
  }
  @override
  Widget build(BuildContext context) {
      return  snapshot==null
          ? Scaffold(
            body: Center(child: CircularProgressIndicator(),),
            )
          :Scaffold(
            appBar: AppBar(
              elevation: 0,
              leading: IconButton(
                onPressed: (){
                  Navigator.pop(context);
                }, icon: Icon(CupertinoIcons.back,color: Colors.white,)
              ),
              title: Text(snapshot!["areaName"],style: const TextStyle(color: Colors.white),),
              centerTitle: true,
          ),
          floatingActionButton: widget.userModel.rights.contains(Rights.addShop)||widget.userModel.rights.contains(Rights.all)
              ?FloatingActionButton.extended(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddShop(areaName: snapshot!["areaName"],areaId: widget.areaId ,userModel: widget.userModel, companyModel: widget.companyModel,)));
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
                      if((snapshot.data.docs[index]["areaId"]==widget.areaId && snapshot.data.docs[index]["isDeleted"]==false&& snapshot.data.docs[index]["isActive"]==true)||widget.userModel.designation==snapshot.data.docs[index]["shopId"]){
                        return ListTile(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderForm(shopId: snapshot.data.docs[index]["shopId"], companyModel: widget.companyModel,userModel: widget.userModel,)));
                          },
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
