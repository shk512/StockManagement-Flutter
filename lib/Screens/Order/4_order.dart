import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Order/view_order.dart';

import '../../Constants/rights.dart';
import '../../Services/DB/order_db.dart';


class Order extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const Order({Key? key, required this.userModel, required this.companyModel}) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  Stream? order;
  TextEditingController searchController=TextEditingController();

  @override
  void initState() {
    super.initState();
    getOrderData();
  }

  getOrderData()async{
    await OrderDB(companyId: widget.companyModel.companyId, orderId: "").getOrder().then((value) {
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
                  hintText: "Search by invoice# or shop name or date",
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
                              if(snapshot.data.docs[index]["orderId"].toString().contains(searchController.text)||snapshot.data.docs[index]["shopDetails"].toString().trim().toLowerCase().contains(searchController.text.trim().toLowerCase())){
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
    Color clr;
    if(snapshot["status"]=="processing".toUpperCase()){
      clr=Colors.red;
    }else if(snapshot["status"]=="dispatch".toUpperCase()){
      clr=Colors.amber;
    }else if(snapshot["status"]=="deliver".toUpperCase()){
      clr=Colors.green;
    }else{
      clr=Colors.black38;
    }
    return ListTile(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewOrder(orderId: snapshot["orderId"],companyModel: widget.companyModel,userModel: widget.userModel,key: Key("viewOrder"),)));
      },
      title: Text("${snapshot["shopDetails"]}"),
      subtitle: Text("${snapshot["dateTime"]}"),
      leading: Icon(Icons.brightness_1,color: clr,size: 15,),
      trailing: Text("Rs. ${snapshot["totalAmount"]}"),
      isThreeLine: true
    );
  }
}
