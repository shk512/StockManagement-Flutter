import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Shop/edit_shop.dart';
import 'package:stock_management/Services/DB/shop_db.dart';

import '../../Constants/narration.dart';
import '../../Constants/rights.dart';
import '../../Functions/create_transaction.dart';
import '../../Functions/update_data.dart';
import '../../Widgets/num_field.dart';
import '../../utils/enum.dart';
import '../../utils/snack_bar.dart';
import '../Splash_Error/error.dart';

class InActiveShop extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const InActiveShop({Key? key, required this.userModel, required this.companyModel}) : super(key: key);

  @override
  State<InActiveShop> createState() => _InActiveShopState();
}

class _InActiveShopState extends State<InActiveShop> {
  Stream? shop;
  TextEditingController searchController=TextEditingController();

  @override
  void initState() {
    super.initState();
    getShop();
  }
  getShop()async{
    await ShopDB(companyId: widget.companyModel.companyId, shopId: "").getInActiveShops().then((value){
      setState(() {
        shop=value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Expanded(
          child: StreamBuilder(
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
                        if(searchController.text.isEmpty){
                          if(widget.userModel.role=="COMPANY"){
                            return listTile(snapshot.data.docs[index]);
                          }else if(widget.userModel.area.contains(snapshot.data.docs[index]["areaId"])){
                            return listTile(snapshot.data.docs[index]);
                          }else{
                            return const SizedBox();
                          }
                        }else{
                          if(snapshot.data.docs[index]["shopName"].toString().trim().toLowerCase().contains(searchController.text.trim().toLowerCase())){
                            if(widget.userModel.role=="COMPANY"){
                              return listTile(snapshot.data.docs[index]);
                            }else if(widget.userModel.area.contains(snapshot.data.docs[index]["areaId"])){
                              return listTile(snapshot.data.docs[index]);
                            }else{
                              return const SizedBox();
                            }
                          }else{
                            return const SizedBox();
                          }
                        }
                      });
                }
              }),)
      ],
    );
  }
  showWarningDialogue(DocumentSnapshot snapshot){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Warning"),
            content: Text("Are you sure to active ${snapshot["shopName"]}?"),
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

  Widget listTile(DocumentSnapshot snapshot){
    return ListTile(
      onTap: (){
        if(widget.userModel.rights.contains(Rights.editShop)||widget.userModel.rights.contains(Rights.all)){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>EditShop(shopId: snapshot["shopId"], userModel: widget.userModel, companyModel: widget.companyModel,key: Key("editShop"),)));
        }
      },
      leading: IconButton(
          onPressed: (){
            showWarningDialogue(snapshot);
          },
          icon: Icon(Icons.update,color: Colors.brown,)),
      title: Text("${snapshot["shopName"]}"),
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
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
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
    accountTransaction(narration, amount, type, shopName, widget.companyModel.companyId, widget.userModel.userId, context).then((value)async{
      if(value==true){
        await ShopDB(companyId: widget.companyModel.companyId, shopId: shopId).updateWallet(-amount).then((value){
          showSnackbar(context, Colors.green.shade300, "Saved");
          setState(() {
            widget.userModel.wallet=widget.userModel.wallet+amount;
            updateUserData(context, widget.userModel);
          });
        }).onError((error, stackTrace){
          Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
        });
      }
    }).onError((error, stackTrace) {
      Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
    });
  }
}
