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
  String areaName="";
  TextEditingController searchController=TextEditingController();

  @override
  void initState() {
    super.initState();
    if(widget.userModel.role=="SHOP KEEPER"){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderForm(shopId: widget.userModel.designation, companyModel: widget.companyModel, userModel: widget.userModel,key: Key("orderForm"),)));
    }else{
      getShops();
    }
    getAreaDetails();
  }
  getAreaDetails() async{
    await AreaDb(areaId: widget.areaId, companyId: widget.companyModel.companyId).getAreaById().then((value) {
      setState(() {
        areaName=value["areaName"];
      });
    });
  }
  getShops()async{
    await ShopDB(companyId: widget.companyModel.companyId, shopId: "").getActiveShopByAreaId(widget.areaId).then((value){
      setState(() {
        shops=value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
      return  areaName.isEmpty
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
              title: Text(areaName,style: const TextStyle(color: Colors.white),),
              centerTitle: true,
          ),
          floatingActionButton: widget.userModel.rights.contains(Rights.addShop)||widget.userModel.rights.contains(Rights.all)
              ?FloatingActionButton.extended(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddShop(areaName: areaName,areaId: widget.areaId ,userModel: widget.userModel, companyModel: widget.companyModel,)));
              },
              icon: const Icon(Icons.add,color: Colors.white,),
              label: const Text("Shop",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
          )
              :const SizedBox(),
          body: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search by shop name",
                    ),
                    onChanged: (val){
                      setState(() {
                        searchController.text=val;
                      });
                    },
                  )
              ),
              Expanded(child: StreamBuilder(
                  stream: shops,
                  builder: (context,snapshot){
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
                          if(searchController.text.isEmpty){
                            return listTile(snapshot.data.docs[index]);
                          }else{
                            if(snapshot.data.docs[index]["shopName"].toString().trim().toLowerCase().contains(searchController.text.trim().toLowerCase())){
                              return listTile(snapshot.data.docs[index]);
                            }else{
                              return const SizedBox();
                            }
                          }
                        },
                      );
                    }
                  }
              ))
            ],
          )
      );
  }
  listTile(DocumentSnapshot snapshot){
    return ListTile(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderForm(shopId: snapshot["shopId"], companyModel: widget.companyModel,userModel: widget.userModel,key: Key("orderForm"),)));
      },
      title: Text("${snapshot["shopName"]}"),
      subtitle: Text("${snapshot["ownerName"]}\t${snapshot["contact"]}"),
    );
  }
}
