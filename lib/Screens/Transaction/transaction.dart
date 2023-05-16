import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
            Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateTransaction(companyModel: widget.companyModel,userModel: widget.userModel,)));
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
}
