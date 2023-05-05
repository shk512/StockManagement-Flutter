import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/get_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Order/order_form.dart';
import 'package:stock_management/Screens/Shop/add_shop.dart';
import 'package:stock_management/Screens/Shop/edit_shop.dart';
import 'package:stock_management/Services/DB/shop_db.dart';

class Shop extends StatefulWidget {
  final String areaName;
  const Shop({Key? key,required this.areaName}) : super(key: key);

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
                          if(snapshot.data.docs[index]["areaId"]==widget.areaName && snapshot.data.docs[index]["isDeleted"]==false){
                            return ListTile(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderForm(shopId: snapshot.data.docs[index]["shopId"])));
                              },
                              leading: Icon(Icons.brightness_1,size: 10,color: snapshot.data.docs[index]["isActive"]?Colors.green:Colors.red,),
                              title: Text("${snapshot.data.docs[index]["shopName"]}"),
                              subtitle: Text("${snapshot.data.docs[index]["ownerName"]}\t${snapshot.data.docs[index]["contact"]}"),
                              trailing: UserModel.role=="Manager".toUpperCase()
                                  ?  IconButton(
                                icon: const Icon(Icons.edit,color: Colors.black38),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>EditShop(shopId: snapshot.data.docs[index]["shopId"])));
                                },
                              )
                                  :const SizedBox(height: 0,),
                            );
                          }else{
                            return const SizedBox(height: 0,);
                          }
                        }else if(tab=="Active".toUpperCase()){
                          if(snapshot.data.docs[index]["isActive"]==true){
                            if(snapshot.data.docs[index]["areaId"]==widget.areaName && snapshot.data.docs[index]["isDeleted"]==false){
                              return ListTile(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderForm(shopId: snapshot.data.docs[index]["shopId"])));
                                },
                                title: Text("${snapshot.data.docs[index]["shopName"]}"),
                                subtitle: Text("${snapshot.data.docs[index]["ownerName"]}\t${snapshot.data.docs[index]["contact"]}"),
                                trailing: UserModel.role=="Manager".toUpperCase()
                                    ?  IconButton(
                                  icon: const Icon(Icons.edit,color: Colors.black38),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>EditShop(shopId: snapshot.data.docs[index]["shopId"])));
                                  },
                                )
                                    :const SizedBox(height: 0,),
                              );
                            }else{
                              return const SizedBox(height: 0,);
                            }
                          }else{
                            return const SizedBox(height: 0,);
                          }
                        }else if(tab=="InActive".toUpperCase()){
                          if(snapshot.data.docs[index]["isActive"]==false){
                            if(snapshot.data.docs[index]["areaId"]==widget.areaName && snapshot.data.docs[index]["isDeleted"]==false){
                              return ListTile(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderForm(shopId: snapshot.data.docs[index]["shopId"])));
                                },
                                title: Text("${snapshot.data.docs[index]["shopName"]}"),
                                subtitle: Text("${snapshot.data.docs[index]["ownerName"]}\t${snapshot.data.docs[index]["contact"]}"),
                                trailing: UserModel.role=="Manager".toUpperCase()
                                    ?  IconButton(
                                  icon: const Icon(Icons.edit,color: Colors.black38),
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>EditShop(shopId: snapshot.data.docs[index]["shopId"])));
                                  },
                                )
                                    :const SizedBox(height: 0,),
                              );
                            }else{
                              return const SizedBox(height: 0,);
                            }
                          }else{
                            return const SizedBox(height: 0,);
                          }
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

}
/*
*
* */