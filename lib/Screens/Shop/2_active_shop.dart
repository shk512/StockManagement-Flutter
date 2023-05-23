import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Shop/edit_shop.dart';
import 'package:stock_management/Services/DB/shop_db.dart';

import '../../Constants/narration.dart';
import '../../Constants/rights.dart';
import '../../Models/account_model.dart';
import '../../Services/DB/account_db.dart';
import '../../Widgets/num_field.dart';
import '../../utils/enum.dart';
import '../../utils/snack_bar.dart';
import '../Splash_Error/error.dart';

class ActiveShop extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const ActiveShop({Key? key, required this.userModel, required this.companyModel}) : super(key: key);

  @override
  State<ActiveShop> createState() => _ActiveShopState();
}

class _ActiveShopState extends State<ActiveShop> {
  Stream? shop;

  @override
  void initState() {
    super.initState();
    getShop();
  }
  getShop()async{
    await ShopDB(companyId: widget.companyModel.companyId, shopId: "").getActiveShops().then((value){
      setState(() {
        shop=value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: shop,
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if(snapshot.hasError){
            return const Center(child: Text("error"),);
          }
          if(!snapshot.hasData){
            return const Center(child: Text("No Data Found"),);
          }
          else{
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context,index){
                  if(widget.userModel.role=="COMPANY"){
                    return ListTile(
                      onTap: (){
                        if(widget.userModel.rights.contains(Rights.editShop)||widget.userModel.rights.contains(Rights.all)){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>EditShop(shopId: snapshot.data.docs[index]["shopId"], userModel: widget.userModel, companyModel: widget.companyModel,)));
                        }
                      },
                      leading: IconButton(
                          onPressed: (){
                            showWarningDialogue(snapshot.data.docs[index]);
                          },
                          icon: Icon(Icons.update,color: Colors.brown,)),
                      title: Text("${snapshot.data.docs[index]["shopName"]}"),
                      subtitle: Text("${snapshot.data.docs[index]["ownerName"]}\t${snapshot.data.docs[index]["contact"]}"),
                      isThreeLine: true,
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          if((widget.userModel.rights.contains(Rights.editShop)||widget.userModel.rights.contains(Rights.all))&&snapshot.data.docs[index]["wallet"]!=0){
                            showTransactionDialogue(snapshot.data.docs[index]["shopId"],"${snapshot.data.docs[index]["shopName"]}-${snapshot.data.docs[index]["areaId"]}");
                          }
                        },
                        icon: Icon(Icons.account_balance_wallet_outlined,color: Colors.white,),
                        label: Text("${snapshot.data.docs[index]["wallet"]}",style: TextStyle(color: Colors.white),),
                      ),
                    );
                  }else if(widget.userModel.area.contains(snapshot.data.docs[index]["areaId"])){
                    return ListTile(
                      onTap: (){
                        if(widget.userModel.rights.contains(Rights.editShop)||widget.userModel.rights.contains(Rights.all)){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>EditShop(shopId: snapshot.data.docs[index]["shopId"], userModel: widget.userModel, companyModel: widget.companyModel,)));
                        }
                      },
                      leading: IconButton(
                          onPressed: (){
                            showWarningDialogue(snapshot.data.docs[index]);
                          },
                          icon: Icon(Icons.notifications_active_rounded)),
                      title: Text("${snapshot.data.docs[index]["shopName"]}"),
                      subtitle: Text("${snapshot.data.docs[index]["ownerName"]}\t${snapshot.data.docs[index]["contact"]}"),
                      isThreeLine: true,
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          if((widget.userModel.rights.contains(Rights.editShop)||widget.userModel.rights.contains(Rights.all))&&snapshot.data.docs[index]["wallet"]!=0){
                            showTransactionDialogue(snapshot.data.docs[index]["shopId"],"${snapshot.data.docs[index]["shopName"]}-${snapshot.data.docs[index]["areaId"]}");
                          }
                        },
                        icon: Icon(Icons.account_balance_wallet_outlined,color: Colors.white,),
                        label: Text("${snapshot.data.docs[index]["wallet"]}",style: TextStyle(color: Colors.white),),
                      ),
                    );
                  }else{
                    return const SizedBox();
                  }
                });
          }
        });
  }
  showWarningDialogue(DocumentSnapshot snapshot){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Warning"),
            content: Text("Are you sure to in-active ${snapshot["shopName"]}?"),
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
