import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_management/Constants/narration.dart';
import 'package:stock_management/Constants/rights.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Screens/Transaction/transaction_form.dart';
import 'package:stock_management/Screens/Transaction/view_transaction.dart';

import '../../Services/DB/account_db.dart';

class Accounts extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const Accounts({Key? key,required this.companyModel,required this.userModel}) : super(key: key);

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  Stream? transactions;
  TextEditingController searchController= TextEditingController();
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
            Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateTransaction(companyModel: widget.companyModel,userModel: widget.userModel,key: Key("createTransaction"),)));
          },
          icon: Icon(Icons.add,color: Colors.white,),
          label: Text("Transaction",style: TextStyle(color: Colors.white),),
      )
          :const SizedBox(),
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by description or date",
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
                      if(searchController.text.isEmpty){
                        return listTile(snapshot.data.docs[index]);
                      }else{
                        String date=DateFormat("yyyy-MM-dd").format(DateTime.parse(snapshot.data.docs[index]["date"]));
                        String str = date.replaceAll(RegExp('[^0-9]'), '');
                        if(snapshot.data.docs[index]["description"].toString().trim().toLowerCase().contains(searchController.text.trim().toLowerCase())||str.contains(searchController.text)){
                          return listTile(snapshot.data.docs[index]);
                        }else{
                          return const SizedBox();
                        }
                      }
                    }
                );
              }
            },
          )
          )
        ],
      ),
    );
  }
  listTile(DocumentSnapshot snapshot){
    return ListTile(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewTransaction(transactionId: snapshot["transactionId"], userModel: widget.userModel, companyModel: widget.companyModel,key: Key("viewTransaction"),)));
      },
      leading: Text("${snapshot["type"]}",style: TextStyle(color: Colors.brown,fontWeight: FontWeight.bold),),
      title: Text("${snapshot["description"]}"),
      subtitle: Text("${snapshot["date"]}"),
      trailing: Text("Rs. ${snapshot["amount"]}",style: TextStyle(color: snapshot["narration"]==Narration.minus?Colors.red:Colors.green,fontWeight: FontWeight.bold)),
      isThreeLine : true,
    );
  }
}
