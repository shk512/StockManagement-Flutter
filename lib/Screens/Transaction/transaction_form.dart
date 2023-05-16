import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Constants/narration.dart';
import '../../Functions/create_transaction.dart';
import '../../Functions/update_data.dart';
import '../../Models/company_model.dart';
import '../../Models/user_model.dart';
import '../../Widgets/num_field.dart';
import '../../utils/enum.dart';
import '../../utils/snack_bar.dart';

class CreateTransaction extends StatefulWidget {
  final UserModel userModel;
  final CompanyModel companyModel;
  const CreateTransaction({Key? key,required this.companyModel, required this.userModel}) : super(key: key);

  @override
  State<CreateTransaction> createState() => _CreateTransactionState();
}

class _CreateTransactionState extends State<CreateTransaction> {
  TextEditingController amount=TextEditingController();
  TextEditingController detail=TextEditingController();
  final formKey=GlobalKey<FormState>();
  TransactionType type=TransactionType.cash;
  Narrate narrate=Narrate.minus;
  String narration=Narration.minus;
  String transactionType="Cash";
  bool isLoading=false;

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
          ElevatedButton(
            onPressed: (){
              if(formKey.currentState!.validate()){
                setState(() {
                  isLoading=true;
                });
                accountTransaction(narration, int.parse(amount.text), transactionType, detail.text,widget.companyModel.companyId,widget.userModel.userId,context).then((value){
                  if(narration==Narration.minus){
                    widget.companyModel.wallet-=int.parse(amount.text);
                  }else{
                    widget.companyModel.wallet+=int.parse(amount.text);
                  }
                  updateCompanyData(context, widget.companyModel).then((value){
                    setState(() {
                      isLoading=false;
                    });
                    Navigator.pop(context);
                    showSnackbar(context, Colors.green.shade300,"Save");
                  });
                });
              }
            },
            child: const Text("Save",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(),)
          :SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                /*
                * TRANSACTION TYPE
                * */
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
                                  transactionType="Cash";
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
                                  transactionType="Online";
                                });
                              })
                      ),
                    )
                  ],
                ),
                /*
                * NARRATION
                * */
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
                                  narration=Narration.plus;
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
                                  narration=Narration.minus;
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
        ),
      ),
    );
  }
}
