import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Screens/User/view_user.dart';
import 'package:stock_management/Services/DB/company_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Constants/narration.dart';
import '../../Models/account_model.dart';
import '../../Services/DB/account_db.dart';
import '../../Widgets/num_field.dart';
import '../../utils/enum.dart';
import '../RegisterLogin/signup.dart';

class Employee extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const Employee({Key? key,required this.companyModel,required this.userModel}) : super(key: key);

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  Stream? user;
  bool isLoading=false;
  TextEditingController searchController=TextEditingController();

  @override
  void initState() {
    super.initState();
    getUser();
  }
  getUser()async{
    await UserDb(id: "").getAllUser(widget.companyModel.companyId).then((value){
      setState(() {
        user=value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator(),)
        :Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(CupertinoIcons.back,color: Colors.white,)
        ),
        title: const Text("Users",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup(companyId: widget.companyModel.companyId,key: Key("signup"),)));
          },
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("User",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by name or designation",
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
            stream: user,
            builder: (context,AsyncSnapshot snapshot){
              if(snapshot.connectionState==ConnectionState.waiting){
                return const Center(child: CircularProgressIndicator(),);
              }
              if(snapshot.hasError){
                return const Center(child: Text("Error"),);
              }
              if(snapshot.hasData) {
                return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context,index){
                      if(searchController.text.isEmpty){
                        return listTile(snapshot.data.docs[index]);
                      }else{
                        if(snapshot.data.docs[index]["name"].toString().trim().toLowerCase().contains(searchController.text.trim().toLowerCase())||snapshot.data.docs[index]["designation"].toString().trim().toLowerCase().contains(searchController.text.trim().toLowerCase())){
                          return listTile(snapshot.data.docs[index]);
                        }else{
                          return const SizedBox();
                        }
                      }
                    });
              }
              else{
                return const Center(child: Text("No Data Found"),);
              }
            },
          ),)
        ],
      ),
    );
  }
  Widget listTile(DocumentSnapshot snapshot){
    return ListTile(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewUser(userId: snapshot["userId"], userModel: widget.userModel,companyModel: widget.companyModel,key: Key('viewUser'),)));
      },
      title: Text("${snapshot["name"]}"),
      subtitle: Text("${snapshot["phone"]}"),
      trailing: ElevatedButton.icon(
          onPressed: (){
            if(snapshot["wallet"]!=0){
              showTransactionDialogue(snapshot["userId"],"${snapshot["name"]}-${snapshot["designation"]}");
            }
          },
          icon: Icon(Icons.account_balance_wallet_outlined,color: Colors.white,),
          label: Text("Rs. ${snapshot["wallet"]}",style: TextStyle(color: Colors.white),)
      ),
    );
  }

  showTransactionDialogue(String userId,String userName){
    final formKey=GlobalKey<FormState>();
    TextEditingController amount=TextEditingController();
    TransactionType type=TransactionType.cash;
    String narration=Narration.plus;
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
                    createTransaction(userId, userName, narration, int.parse(amount.text),tempType);
                    Navigator.pop(context);
                  }
                }, child: Text("Save",style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        });
  }
  createTransaction(String userId,String userName,String narration,num amount,String type) async{
    String transactionId=DateTime.now().microsecondsSinceEpoch.toString();
    await AccountDb(companyId: widget.companyModel.companyId, transactionId: transactionId).saveTransaction(
        AccountModel.toJson(
            transactionId: transactionId,
            transactionBy: widget.userModel.userId,
            desc: userName,
            narration: narration,
            amount: amount,
            type: type,
            dateTime: DateTime.now().toString()
        )
    ).then((value)async{
      if(value==true){
        await UserDb(id: userId).updateWalletBalance(-amount).then((value)async{
          await CompanyDb(id: widget.companyModel.companyId).updateWallet(amount).then((value) {
            showSnackbar(context, Colors.green.shade300, "Saved");
            setState(() {
              widget.companyModel.wallet=amount;
            });
          }).onError((error, stackTrace){
            Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
          });
        }).onError((error, stackTrace){
          Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
        });
      }else{
        showSnackbar(context, Colors.red.shade400, value.toString());
      }
    }).onError((error, stackTrace) {
      Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
    });
  }
}
