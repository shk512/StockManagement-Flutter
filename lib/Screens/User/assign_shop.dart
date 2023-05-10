import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Services/DB/shop_db.dart';

class AssignShop extends StatefulWidget {
  final userId;
  const AssignShop({Key? key,required this.userId}) : super(key: key);

  @override
  State<AssignShop> createState() => _AssignShopState();
}

class _AssignShopState extends State<AssignShop> {
  Stream? shops;
  DocumentSnapshot? snapshot;

  @override
  void initState() {
    super.initState();
    getShops();
    getUserDetails();
  }
  getUserDetails()async{
    await UserDb(id: widget.userId).getData().then((value){
      setState(() {
        snapshot=value;
      });
    });
  }
  getShops()async{
    await ShopDB(companyId: snapshot!["companyId"], shopId: "").getShops().then((value){
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
