import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Constants/narration.dart';
import 'package:stock_management/Constants/rights.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Screens/Transaction/view_transaction.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Models/account_model.dart';
import '../../Services/DB/account_db.dart';
import '../../Services/DB/company_db.dart';
import '../../Widgets/num_field.dart';
import '../../utils/enum.dart';

class Accounts extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const Accounts({Key? key,required this.companyModel,required this.userModel}) : super(key: key);

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  Stream? transactions;

  @override
  void initState() {
    super.initState();
    getTransaction();
  }
  getTransaction()async{
    await AccountDb(companyId: widget.companyModel.companyId, transactionId: "").getTransaction().then((value) {
      setState(() {
        transactions=value;
      });
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
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
        title: const Text("Transactions",style: TextStyle(color: Colors.white),),
        actions: [
          Icon(Icons.account_balance_wallet_outlined,color: Colors.white,),
          Align(
              alignment: Alignment.center,
              child: Text("Rs. ${widget.companyModel.wallet}\t",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
        ],
      ),
      floatingActionButton: widget.userModel.rights.contains(Rights.addTransaction)||widget.userModel.rights.contains(Rights.all)
          ?FloatingActionButton.extended(
          onPressed: (){
            showTransactionDialogue();
          },
          icon: Icon(Icons.add,color: Colors.white,),
          label: Text("Transaction",style: TextStyle(color: Colors.white),),
      )
          :const SizedBox(),
      body: StreamBuilder(
        stream: transactions,
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if(snapshot.hasError){
            return const Center(child: Text("Error"),);
          }
          if(!snapshot.hasData){
            return const Center(child: Text("No Data Found"),);
          }
          else{
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context,index){
                  return ListTile(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewTransaction(transactionId: snapshot.data.docs[index]["transactionId"], userModel: widget.userModel, companyModel: widget.companyModel,)));
                    },
                    leading: Text("${snapshot.data.docs[index]["type"]}",style: TextStyle(color: Colors.brown,fontWeight: FontWeight.bold),),
                    title: Text("${snapshot.data.docs[index]["description"]}"),
                    subtitle: Text("${snapshot.data.docs[index]["date"]}"),
                    trailing: Text("Rs. ${snapshot.data.docs[index]["amount"]}",style: TextStyle(color: snapshot.data.docs[index]["narration"]==Narration.minus?Colors.red:Colors.green,fontWeight: FontWeight.bold)),
                    isThreeLine : true,
                  );
                }
            );
          }
        },
      ),
    );
  }
  showTransactionDialogue(){
    TextEditingController amount=TextEditingController();
    TextEditingController detail=TextEditingController();
    final formKey=GlobalKey<FormState>();
    TransactionType type=TransactionType.cash;
    Narrate narrate=Narrate.minus;

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
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                            title: Text(
                              "Plus",
                              style: const TextStyle(color:Colors.green,fontWeight: FontWeight.bold),
                            ),
                            leading: Radio(
                                value: Narrate.plus,
                                groupValue: narrate,
                                onChanged: (value) {
                                  setState(() {
                                    narrate = value!;
                                  });
                                })
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                            title: Text(
                              "Minus",
                              style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.red),
                            ),
                            leading: Radio(
                                value: Narrate.minus,
                                groupValue: narrate,
                                onChanged: (value) {
                                  setState(() {
                                    narrate = value!;
                                  });
                                })
                        ),
                      )
                    ],
                  ),
                  NumField(icon: Icon(Icons.onetwothree_outlined), ctrl: amount, hintTxt: "In digits", labelTxt: "Amount Received"),
                  TextFormField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Transaction Description",
                    ),
                    controller: detail,
                    validator: (val){
                      return val!.isNotEmpty?null:"Invalid";
                    },
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel",style: TextStyle(color: Colors.white),)),
              ElevatedButton(
                  onPressed: ()async{
                    Navigator.pop(context);
                    String tempType="";
                    if(type==TransactionType.cash){
                      tempType="Cash";
                    }else{
                      tempType="Online";
                    }
                    if(formKey.currentState!.validate()){
                      Navigator.pop(context);
                      createTransaction(narrate==Narrate.minus?Narration.minus:Narration.plus, int.parse(amount.text), tempType,detail.text);
                    }
                  },
                  child: const Text("Submit",style: TextStyle(color: Colors.white),)
              )
            ],
          );
        });
  }
  createTransaction(String narration,num amount,String type,String desc) async{
    String transactionId=DateTime.now().microsecondsSinceEpoch.toString();
    await AccountDb(companyId: widget.companyModel.companyId, transactionId: transactionId).saveTransaction(
        AccountModel.toJson(
            transactionId: transactionId,
            transactionBy: widget.userModel.userId,
            desc: desc,
            narration: narration,
            amount: amount,
            type: type,
            dateTime: DateTime.now().toString()
        )).then((value)async{
          num tempAmount=amount;
          if(narration==Narration.minus){
            tempAmount=-amount;
          }
          await CompanyDb(id: widget.companyModel.companyId).updateWallet(tempAmount).then((value){
            showSnackbar(context, Colors.green.shade300, "Saved");
            setState(() {

            });
          }).onError((error, stackTrace) => Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
    }).onError((error, stackTrace) {
      Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}
