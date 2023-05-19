import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Widgets/row_info_display.dart';

import '../../Constants/narration.dart';
import '../../Functions/create_transaction.dart';
import '../../Functions/update_data.dart';
import '../../Models/company_model.dart';
import '../../Models/order_model.dart';
import '../../Models/user_model.dart';
import '../../Services/DB/order_db.dart';
import '../../Services/DB/shop_db.dart';
import '../../Widgets/num_field.dart';
import '../../utils/enum.dart';
import '../../utils/snack_bar.dart';
import '../Splash_Error/error.dart';

class DeliverForm extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  final orderId;
  const DeliverForm({Key? key,required this.orderId, required this.companyModel, required this.userModel}) : super(key: key);

  @override
  State<DeliverForm> createState() => _DeliverFormState();
}

class _DeliverFormState extends State<DeliverForm> {
  TextEditingController amount=TextEditingController();
  TextEditingController concession=TextEditingController();
  TextEditingController detail=TextEditingController();
  final formKey=GlobalKey<FormState>();
  bool isLoading=false;
  TransactionType type=TransactionType.cash;
  String narration=Narration.minus;
  String transactionType="Cash";
  DocumentSnapshot? orderSnapshot;

  @override
  void initState() {
    super.initState();
    getOrderData();
  }

  getOrderData() async{
    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderId).getOrderById().then((value)async{
      setState(() {
        orderSnapshot=value;
        OrderModel.products=List.from(value["products"]);
        OrderModel.totalAmount=value["totalAmount"];
      });
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),))));
  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: const Text("Deliver Form",style: TextStyle(color: Colors.white),),
        actions: [
          ElevatedButton(
            onPressed: (){
              if(formKey.currentState!.validate()){
                setState(() {
                  isLoading=true;
                });
                Map<String,dynamic> mapData={
                  "advanceAmount":orderSnapshot!["advanceAmount"]+int.parse(amount.text),
                  "balanceAmount":orderSnapshot!["balanceAmount"]-int.parse(amount.text)-int.parse(concession.text),
                  "concessionAmount": int.parse(concession.text),
                  "description":detail.text,
                  "deliverBy":widget.userModel.userId
                };
                updateOrderDetails(context, mapData, widget.companyModel.companyId, widget.orderId).then((value){
                  accountTransaction(narration, int.parse(amount.text), transactionType, orderSnapshot!["shopDetails"],widget.companyModel.companyId,widget.userModel.userId,context).then((value){
                    widget.userModel.wallet+=int.parse(amount.text);
                    updateUserData(context, widget.userModel).then((value)async{
                      await ShopDB(companyId: widget.companyModel.companyId, shopId: orderSnapshot!["shopId"]).updateWallet(-(int.parse(amount.text)+int.parse(concession.text))).then((value)async{
                        updateOrderStatus();
                        setState(() {
                          isLoading=false;
                        });
                        Navigator.pop(context);
                        Navigator.pop(context);
                        showSnackbar(context, Colors.green.shade300,"Delivered");
                      });
                    });
                });
                });
              }
            },
            child: const Text("Save",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          ),
        ],
      ),
      body: isLoading || orderSnapshot==null
          ? const Center(child: CircularProgressIndicator(),)
          :SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                RowInfoDisplay(value: "${orderSnapshot!["balanceAmount"]}", label: "Balance Amount"),
                const SizedBox(height: 10,),
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
                            transactionType="Cash";
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
                            transactionType="Online";
                          });
                        })
                ),
                NumField(icon: Icon(Icons.onetwothree_outlined), ctrl: amount, hintTxt: "In digits", labelTxt: "Amount Received"),
                NumField(icon: Icon(Icons.onetwothree_outlined), ctrl: concession, hintTxt: "In digits", labelTxt: "Concession Amount"),
                TextField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Details (if-any)",
                  ),
                  controller: detail,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  updateOrderStatus()async{
    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderId).updateOrder({
      "status":"Deliver".toUpperCase()
    }).then((value){
      if(value==true){
        setState(() {
          OrderModel.products=[];
          OrderModel.totalAmount=0;
        });
        Navigator.pop(context);
      }else{
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}
