import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Widgets/row_info_display.dart';

import '../../Constants/narration.dart';
import '../../Constants/routes.dart';
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
  final OrderModel orderModel;
  const DeliverForm({Key? key,required this.orderModel, required this.companyModel, required this.userModel}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
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
                widget.orderModel.advanceAmount+=int.parse(amount.text);
                widget.orderModel.balanceAmount=widget.orderModel.balanceAmount-int.parse(amount.text)-int.parse(concession.text);
                widget.orderModel.description=detail.text;
                widget.orderModel.deliverBy=widget.userModel.userId;
                updateOrderDetails(context, widget.orderModel, widget.companyModel.companyId).then((value){
                  accountTransaction(narration, int.parse(amount.text), transactionType, widget.orderModel.shopDetails,widget.companyModel.companyId,widget.userModel.userId,context).then((value){
                    widget.userModel.wallet+=int.parse(amount.text);
                    updateUserData(context, widget.userModel).then((value)async{
                      await ShopDB(companyId: widget.companyModel.companyId, shopId:widget.orderModel.shopId).updateWallet(-(int.parse(amount.text)+int.parse(concession.text))).then((value)async{
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(),)
          :SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                RowInfoDisplay(value: "${widget.orderModel.balanceAmount}", label: "Balance Amount"),
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
    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderModel.orderId).updateOrder({
      "status":"Deliver".toUpperCase()
    }).then((value){
      if(value==true){
        Navigator.pushNamedAndRemoveUntil(context, Routes.dashboard , (route) => false);
      }else{
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
    });
  }
}
