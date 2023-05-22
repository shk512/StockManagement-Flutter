import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/account_model.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Shop/edit_shop.dart';
import 'package:stock_management/Services/DB/account_db.dart';
import 'package:stock_management/Services/DB/shop_db.dart';
import 'package:stock_management/Widgets/num_field.dart';
import 'package:stock_management/utils/enum.dart';

import '../../Constants/narration.dart';
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
  int quantityOfShops=0;

  @override
  void initState() {
    super.initState();
    getShops();
    quantityOfShops=0;
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
                  //ALL
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(18),bottomLeft: Radius.circular(18)),
                      ),
                      alignment: AlignmentDirectional.center,
                      child: const Text("ALL",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  //AREA WISE
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.brown.shade300,
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(18),bottomRight: Radius.circular(18)),
                      ),
                      alignment: AlignmentDirectional.center,
                      child: const Text("AREA WISE",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
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
                        if(tab=="all".toUpperCase()&&snapshot.data.docs[index]["isDeleted"]==false){
                          return listTile(snapshot.data.docs[index]);
                        }else if(tab=="Active".toUpperCase() && snapshot.data.docs[index]["isActive"]==true &&snapshot.data.docs[index]["isDeleted"]==false){
                          return listTile(snapshot.data.docs[index]);
                        }else if(tab=="InActive".toUpperCase() && snapshot.data.docs[index]["isActive"]==false &&snapshot.data.docs[index]["isDeleted"]==false){
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
      leading: tab=="all".toUpperCase()
          ? ElevatedButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.white)
        ),
        onPressed: (){
          if(widget.userModel.rights.contains(Rights.changeShopStatus)|| widget.userModel.rights.contains(Rights.all)){
            showWarningDialogue(snapshot);
          }
        },
          label: Text("${++quantityOfShops}",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),),
          icon: Icon(Icons.brightness_1,size: 10,color: snapshot["isActive"]?Colors.green:Colors.red,)
      ):Text("${++quantityOfShops}",style: TextStyle(fontWeight: FontWeight.bold),),
      title: Text("${snapshot["shopName"]}-${snapshot["areaId"]}"),
      subtitle: Text("${snapshot["ownerName"]}\t${snapshot["contact"]}"),
      isThreeLine: true,
      trailing: ElevatedButton.icon(
        onPressed: () {
          if((widget.userModel.rights.contains(Rights.editShop)||widget.userModel.rights.contains(Rights.all))&&snapshot["wallet"]!=0){
            showTransactionDialogue(snapshot["shopId"],"${snapshot["shopName"]}-${snapshot["areaId"]}");
          }
        },
        icon: Icon(Icons.account_balance_wallet_outlined,color: Colors.white,),
        label: Text("${snapshot["wallet"]}",style: TextStyle(color: Colors.white),),
      ),
    );
  }
  showWarningDialogue(DocumentSnapshot snapshot){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
           title: Text("Warning"),
           content: Text("Are you sure to inactive ${snapshot["shopName"]}?"),
           actions: [
             IconButton(
               onPressed: (){
                 Navigator.pop(context);
               }, icon: Icon(Icons.cancel,color: Colors.red),),
             IconButton(
               onPressed: (){
                 Navigator.pop(context);
                 updateStatus(snapshot);
               }, icon: Icon(Icons.check_circle_rounded,color: Colors.green),),
           ],
          );
        });
  }
  updateStatus(DocumentSnapshot snapshot)async{
    await ShopDB(companyId: widget.companyModel.companyId, shopId: snapshot["shopId"]).updateShop({
      "isActive":!snapshot["isActive"]
    }).then((value){
      if(value==true){
        showSnackbar(context, Colors.green.shade300, "Updated");
      }else{
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  showTransactionDialogue(String shopId,String shopName){
    final formKey=GlobalKey<FormState>();
    TextEditingController amount=TextEditingController();
    TransactionType type=TransactionType.cash;
    String narration=Narration.minus;
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Transaction Form"),
            content: Form(
              key: formKey,
                child: Column(
                  children: [
                    ListTile(
                        title: Text(
                          "Cash",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        leading: Radio(
                            value: TransactionType.cash,
                            groupValue: type,
                            onChanged: (value) {
                              setState(() {
                                type = value!;
                              });
                            })
                    ),
                    ListTile(
                        title: Text(
                          "Online",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        leading: Radio(
                            value: TransactionType.online,
                            groupValue: type,
                            onChanged: (value) {
                              setState(() {
                                type = value!;
                              });
                            })
                    ),
                    NumField(icon: Icon(Icons.currency_ruble_outlined), ctrl: amount, hintTxt: "In digits", labelTxt: "Amount Received")
                  ],
                ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  }, child: const Text("Cancel",style: TextStyle(color: Colors.white),),
              ),
              ElevatedButton(
                onPressed: (){
                  if(formKey.currentState!.validate()){
                    String tempType="";
                    if(type==TransactionType.cash){
                      tempType="Cash";
                    }else{
                      tempType="Online";
                    }
                    createTransaction(shopId, shopName, narration, int.parse(amount.text),tempType);
                    Navigator.pop(context);
                  }
                }, child: Text("Save",style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        });
  }
  createTransaction(String shopId,String shopName,String narration,num amount,String type) async{
    String transactionId=DateTime.now().microsecondsSinceEpoch.toString();
    await AccountDb(companyId: widget.companyModel.companyId, transactionId: transactionId).saveTransaction(
        AccountModel.toJson(
            transactionId: transactionId,
            transactionBy: widget.userModel.userId,
            desc: shopName,
            narration: narration,
            amount: amount,
            type: type,
            dateTime: DateTime.now().toString()
        )
    ).then((value)async{
      if(value==true){
        await ShopDB(companyId: widget.companyModel.companyId, shopId: shopId).updateWallet(-amount).then((value){
          showSnackbar(context, Colors.green.shade300, "Saved");
          setState(() {

          });
        }).onError((error, stackTrace){
          Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
        });
      }
    }).onError((error, stackTrace) {
      Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}
