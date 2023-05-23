import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Order/view_order.dart';
import 'package:stock_management/Services/DB/order_db.dart';

import '../../Constants/rights.dart';
import '../../Models/company_model.dart';

class DeliverOrder extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const DeliverOrder({Key? key, required this.userModel, required this.companyModel}) : super(key: key);

  @override
  State<DeliverOrder> createState() => _DeliverOrderState();
}

class _DeliverOrderState extends State<DeliverOrder> {
  Stream? order;

  @override
  void initState() {
    super.initState();
    getOrder();
  }
  getOrder() async{
    await OrderDB(companyId: widget.companyModel.companyId, orderId: "").getDeliverOrder().then((value){
      setState(() {
        order=value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
              stream: order,
              builder: (context, snapshot){
                if(snapshot.connectionState==ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator(),);
                }
                if(snapshot.hasError){
                  return const Center(child: Text("error"),);
                }
                if(!snapshot.hasData){
                  return const Center(child: Text("No Data Found"),);
                }
                else{
                  return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index){
                        /*
                    * ENTERTAINS COMPANY
                    * */
                        if(widget.userModel.rights.contains(Rights.all)){
                          return  listTile(snapshot.data.docs[index]);
                        }
                        /*
                * ENTERTAINS EMPLOYEE
                * */
                        else if(snapshot.data.docs[index]["orderBy"]==widget.userModel.userId||snapshot.data.docs[index]["deliverBy"]==widget.userModel.userId||snapshot.data.docs[index]["shopId"]==widget.userModel.designation){
                          return  listTile(snapshot.data.docs[index]);
                        }
                        else{
                          return const SizedBox();
                        }
                      });
                }
              }
              );
  }
  Widget listTile(DocumentSnapshot snapshot){
    return ListTile(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewOrder(orderId: snapshot["orderId"],companyModel: widget.companyModel,userModel: widget.userModel,)));
        },
        title: Text("${snapshot["shopDetails"]}"),
        subtitle: Text("${snapshot["dateTime"]}"),
        trailing: Text("Rs. ${snapshot["totalAmount"]}"),
        isThreeLine: true
    );
  }
}
