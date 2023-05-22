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
                    child: Container(
                      alignment: Alignment.center,
                      decoration:  BoxDecoration(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(18),bottomLeft: Radius.circular(18)),
                        color: Colors.brown.shade300,
                      ),
                      child:const Text("PROCESS",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  //DISPATCH
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(18),bottomLeft: Radius.circular(18)),
                        color: Colors.brown.shade300,
                      ),
                      child:const Text("DISPATCH",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  //DELIVERED
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(18),bottomLeft: Radius.circular(18)),
                        color: Colors.brown.shade300,
                      ),
                      child:const Text("DELIVERED",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  //ALL
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        borderRadius:  BorderRadius.only(topLeft: Radius.circular(18),bottomLeft: Radius.circular(18)),
                        color: Colors.brown,
                      ),
                      child:const Text("ALL",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                    ),
                  ),
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
      leading: Icon(Icons.brightness_1,color: clr,size: 15,),
      trailing: Text("Rs. ${snapshot["totalAmount"]}"),
      isThreeLine: true
    );
  }
}
