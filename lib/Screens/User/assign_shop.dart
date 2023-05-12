import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Services/DB/shop_db.dart';

class AssignShop extends StatefulWidget {
  final companyId;
  final userId;
  const AssignShop({Key? key,required this.userId,required this.companyId}) : super(key: key);

  @override
  State<AssignShop> createState() => _AssignShopState();
}

class _AssignShopState extends State<AssignShop> {
  Stream? shops;
  DocumentSnapshot? userSnapshot;

  @override
  void initState() {
    super.initState();
    getShops();
  }
  getShops()async{
    await ShopDB(companyId: widget.companyId, shopId: "").getShops().then((value){
      setState(() {
        shops=value;
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
        title: Text("Shop",style: const TextStyle(color: Colors.white),),
      ),
      body: shops==null
          ? const Center(child: CircularProgressIndicator(),)
          :StreamBuilder(
        stream: shops,
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if(snapshot.hasError){
            return const Center(child: Text("Error"),);
          }
          if(!snapshot.hasData){
            return const Center(child: Text("No Data"),);
          }
          else{
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context,index){
                  return listTile(snapshot.data.docs[index]);
                });
          }
        },
      ),
    );
  }
  listTile(DocumentSnapshot snapshot){
    return ListTile(
      onTap: (){
        updateShop(snapshot["shopId"]);
      },
      title: Text("${snapshot["shopName"]}-${snapshot["areaId"]}"),
      subtitle: Text("${snapshot["ownerName"]}\t${snapshot["contact"]}"),
    );
  }
  updateShop(String shopId) async{
    await UserDb(id: widget.userId).updateUser({
      "designation":shopId
    }).then((value){
      Navigator.pop(context);
      showSnackbar(context, Colors.cyan, "Saved shop");
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}
