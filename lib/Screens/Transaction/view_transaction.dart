import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Constants/narration.dart';
import 'package:stock_management/Models/account_model.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/account_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/Widgets/row_info_display.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Constants/rights.dart';
import '../../Functions/update_data.dart';
import '../../Models/user_model.dart';

class ViewTransaction extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  final String transactionId;
  const ViewTransaction({Key? key,required this.transactionId,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<ViewTransaction> createState() => _ViewTransactionState();
}

class _ViewTransactionState extends State<ViewTransaction> {
  DocumentSnapshot? transactionSnapshot;
  DocumentSnapshot? userSnapshot;
  @override
  void initState() {
    super.initState();
    getTransactionData();
  }
  getTransactionData()async{
    await AccountDb(companyId: widget.companyModel.companyId, transactionId: widget.transactionId).getTransactionDetail().then((value) async{
      setState(() {
        transactionSnapshot=value;
      });
      await UserDb(id: value["transactionBy"]).getData().then((value){
        setState(() {
          userSnapshot=value;
        });
      }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),))));
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),))));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(CupertinoIcons.back,color: Colors.white,)
        ),
        title: Text(widget.transactionId,style: const TextStyle(color: Colors.white),),
        actions: [
          widget.userModel.rights.contains(Rights.rollBackTransaction)||widget.userModel.rights.contains(Rights.all)
              ?IconButton(
              onPressed: (){
                showConfirmDialgue();
              },
              icon: Icon(Icons.replay_circle_filled_rounded,color: Colors.white,))
              :const SizedBox()
        ],
      ),
      body: transactionSnapshot==null||userSnapshot==null
          ?const Center(child: CircularProgressIndicator(),)
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              RowInfoDisplay(value: transactionSnapshot!["description"], label: "Description"),
              RowInfoDisplay(value: "${transactionSnapshot!["amount"]}", label: "Amount"),
              RowInfoDisplay(value: userSnapshot!["name"], label: "Transaction By"),
              RowInfoDisplay(value: transactionSnapshot!["narration"], label: "Narration"),
              RowInfoDisplay(value: transactionSnapshot!["date"], label: "Date-Time"),
              RowInfoDisplay(value: "${transactionSnapshot!["type"]}", label: "Transaction Type")
            ],
          ),
        ),
      ),
    );
  }
  showConfirmDialgue(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Message"),
            content: Text("Are you sure to roll back this transaction?"),
            actions: [
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.cancel,color: Colors.red,)),
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                    rollBackTransaction();
                  }, icon: Icon(Icons.check_circle_rounded,color: Colors.green,)),
            ],
          );
        });
  }
  rollBackTransaction()async{
    String transactionId=DateTime.now().microsecondsSinceEpoch.toString();
    await AccountDb(companyId: widget.companyModel.companyId, transactionId: transactionId).saveTransaction(
        AccountModel.toJson(
            transactionId: transactionId,
            transactionBy: widget.userModel.userId,
            desc: transactionSnapshot!["description"],
            narration: transactionSnapshot!["narration"]==Narration.minus?Narration.plus:Narration.minus,
            amount: transactionSnapshot!["amount"],
            type: "ROLL BACK",
            dateTime: DateTime.now().toString())
    ).then((value)async{
      if(value==true){
        if(transactionSnapshot!["narration"]==Narration.minus){
          widget.companyModel.wallet+=transactionSnapshot!["amount"];
          updateCompanyData(context, widget.companyModel);
        }else{
          widget.companyModel.wallet-=transactionSnapshot!["amount"];
          updateCompanyData(context, widget.companyModel);
        }
      }else{
        showSnackbar(context,Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),))));
  }
}
