import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/account_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/Widgets/row_info_display.dart';

import '../../Constants/rights.dart';
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
      }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
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
              onPressed: (){},
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
}
