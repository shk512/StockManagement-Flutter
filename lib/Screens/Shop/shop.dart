import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/shop_model.dart';
import 'package:stock_management/Services/DB/shop_db.dart';
import 'package:stock_management/Widgets/floating_action_button.dart';
import 'package:stock_management/utils/snackBar.dart';
import '../../utils/routes.dart';

class Shop extends StatefulWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  var shops;

  @override
  void initState() {
    super.initState();
    getShops();
  }
  getShops()async{
    var request=await ShopDB(id: "").getShops();
    setState(() {
      shops=request;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: const Text("Shop",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionBtn(route: Routes.shop, name: "Shop"),
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
                  ShopModel.fromJson(snapshot.data.docs);
                }
            );
          }
        },
      ),
    );
  }
  deleteArea(String id)async{
    await ShopDB(id: id).deleteShop().then((value){
      if(value){
        setState(() {

        });
        showSnackbar(context,Colors.cyan, "Deleted");
      }else{
        showSnackbar(context,Colors.cyan,"Error");
      }
    });
  }
}
