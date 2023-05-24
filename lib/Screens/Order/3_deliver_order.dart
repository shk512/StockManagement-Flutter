import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  TextEditingController searchController=TextEditingController();

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
    return Scaffold(
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search by invoice# or shop name",
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
                            if(searchController.text.isEmpty){
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
                            }else{
                              String date=DateFormat("yyyy-MM-dd").format(DateTime.parse(snapshot.data.docs[index]["dateTime"]));
                              String str = date.replaceAll(RegExp('[^0-9]'), '');
                              if(snapshot.data.docs[index]["orderId"].toString().contains(searchController.text)||snapshot.data.docs[index]["shopDetails"].toString().trim().toLowerCase().contains(searchController.text.trim().toLowerCase())||str.contains(searchController.text)){
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
                              }else{
                                return const SizedBox();
                              }
                            }
                          });
                    }
                  }
              ))
        ],
      ),
    );
  }
  Widget listTile(DocumentSnapshot snapshot){
    return ListTile(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewOrder(orderId: snapshot["orderId"],companyModel: widget.companyModel,userModel: widget.userModel,key: Key("viewOrder"),)));
        },
        title: Text("${snapshot["shopDetails"]}"),
        subtitle: Text("${snapshot["dateTime"]}"),
        trailing: Text("Rs. ${snapshot["totalAmount"]}"),
        isThreeLine: true
    );
  }
}
