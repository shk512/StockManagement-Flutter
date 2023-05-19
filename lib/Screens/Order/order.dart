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
  Stream<QuerySnapshot>? order;
  String tab="Processing".toUpperCase();

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*
          *
          * TAB
          *
          * */
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            child: SizedBox(
              height: 25,
              child: Row(
                children: [
                  //PROCESSING
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          tab="processing".toUpperCase();
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(18),bottomLeft: Radius.circular(18)),
                          color: tab=="processing".toUpperCase()?Colors.brown :Colors.brown.shade200,
                        ),
                        child:const Text("PROCESS",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                      ),
                    ),
                  ),
                  //DISPATCH
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          tab="dispatch".toUpperCase();
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: tab=="dispatch".toUpperCase()?Colors.brown :Colors.brown.shade200
                        ),
                        child: const Text("DISPATCH",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  //DELIVERED
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          tab="deliver".toUpperCase();
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: tab=="deliver".toUpperCase()?Colors.brown :Colors.brown.shade200,
                        ),
                        child: const Text("DELIVERED",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  //ALL
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          tab="all".toUpperCase();
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(topRight: Radius.circular(18),bottomRight: Radius.circular(18)),
                          color: tab=="all".toUpperCase()?Colors.brown :Colors.brown.shade200,
                        ),
                        child: const Text("ALL",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),),
                ],
              ),
            ),
          ),
          /*
          *
          * STREAM
          *
          * */
          Expanded(
            child: StreamBuilder(
                stream: order,
                builder: (context,AsyncSnapshot snapshot){
                  if(snapshot.connectionState==ConnectionState.waiting){
                    return const Center(child: CircularProgressIndicator(),);
                  }
                  if(snapshot.hasError){
                    return const Center(child: Text("Error"),);
                  }
                  if(!snapshot.hasData){
                    return const Center(child: Text("No Data Found"),);
                  }
                  if(snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          /*
                              * ENTERTAINS COMPANY
                              * */
                          if(widget.userModel.rights.contains(Rights.all)){
                            if(tab.toUpperCase()=="All".toUpperCase()){
                              return  listTile(snapshot.data.docs[index]);
                            }
                            else{
                              if(snapshot.data.docs[index]["status"]==tab.toUpperCase()){
                                return  listTile(snapshot.data.docs[index]);
                              }else{
                                return const SizedBox();
                              }
                            }
                          }
                          /*
                              * ENTERTAINS EMPLOYEE
                              * */
                          else if(snapshot.data.docs[index]["orderBy"]==widget.userModel.userId||snapshot.data.docs[index]["deliverBy"]==widget.userModel.userId||snapshot.data.docs[index]["shopId"]==widget.userModel.designation){
                            if(tab.toUpperCase()=="All".toUpperCase()){
                              return  listTile(snapshot.data.docs[index]);
                            }else{
                              if(snapshot.data.docs[index]["status"]==tab.toUpperCase()){
                                return listTile(snapshot.data.docs[index]);
                              }else{
                                return const SizedBox();
                              }
                            }
                          }
                          else{
                            return const SizedBox();
                          }
                        }
                    );
                  }else{
                    return const Center(child: Text("Something Error"),);
                  }
                }),)
        ],
      )
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
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewOrder(orderId: snapshot["orderId"],companyModel: widget.companyModel,userModel: widget.userModel,)));
      },
      title: Text("${snapshot["shopDetails"]}"),
      subtitle: Text("${snapshot["dateTime"]}"),
      trailing: tab=="all".toUpperCase()?Icon(Icons.brightness_1,color: clr,size: 10,):const SizedBox(),
      leading: Text("Rs. ${snapshot["totalAmount"]}"),
      isThreeLine: true
    );
  }
}
