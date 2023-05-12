import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Screens/User/view_user.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Services/DB/company_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/Services/shared_preferences/spf.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Constants/narration.dart';
import '../../Constants/rights.dart';
import '../../Constants/routes.dart';
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

  @override
  void initState() {
    super.initState();
    getUser();
  }
  getUser()async{
    var request=await UserDb(id: "").getAllUser();
      setState(() {
        user=request;
      });
  }
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator(),)
        :Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: const Text("Users",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup(companyId: widget.companyModel.companyId)));
          },
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("User",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
      body: StreamBuilder(
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
                  if(widget.companyModel.companyId==snapshot.data.docs[index]["companyId"]){
                    return ListTile(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewUser(userId: snapshot.data.docs[index]["userId"], userModel: widget.userModel,companyModel: widget.companyModel,)));
                      },
                        title: Text("${snapshot.data.docs[index]["name"]}"),
                        subtitle: Text("${snapshot.data.docs[index]["phone"]}"),
                        leading: widget.userModel.rights.contains(Rights.deleteUser)||widget.userModel.rights.contains(Rights.all)
                            ?IconButton(
                            onPressed: (){
                              showWarningDialogue(snapshot.data.docs[index]);
                            },
                            icon: Icon(Icons.brightness_1,color: snapshot.data.docs[index]["isDeleted"]?Colors.red:Colors.green,))
                            :const SizedBox(),
                      trailing: ElevatedButton.icon(
                          onPressed: (){
                            showTransactionDialogue(snapshot.data.docs[index]["userId"],"${snapshot.data.docs[index]["name"]}-${snapshot.data.docs[index]["designation"]}");
                          },
                          icon: Icon(Icons.wallet,color: Colors.white,),
                          label: Text("Rs. ${snapshot.data.docs[index]["wallet"]}",style: TextStyle(color: Colors.white),)
                      ),
                    );
                  }else{
                    return const SizedBox();
                  }
                });
          }
          else{
            return const Center(child: Text("No Data Found"),);
          }
        },
      ),
    );
  }
  showWarningDialogue(DocumentSnapshot snapshot){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Warning"),
            content: Text("Are you sure to perform this action?"),
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
    await UserDb(id: snapshot["userId"]).deleteUser(!snapshot["isDeleted"]).then((value)async{
      if(snapshot["userId"]==FirebaseAuth.instance.currentUser!.uid){
        await SPF.saveUserLogInStatus(false);
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
      }else{
        setState(() {
          isLoading=false;
        });
        showSnackbar(context, Colors.cyan, "Updated");
      }
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
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
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
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
                      ),
                      Expanded(
                        child: ListTile(
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
                      )
                    ],
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
            showSnackbar(context, Colors.cyan, "Saved");
            setState(() {
              widget.companyModel.wallet=amount;
            });
          }).onError((error, stackTrace){
            Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
          });
        }).onError((error, stackTrace){
          Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
        });
      }else{
        showSnackbar(context, Colors.red, value.toString());
      }
    }).onError((error, stackTrace) {
      Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}
