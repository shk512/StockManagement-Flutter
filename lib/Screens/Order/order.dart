import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Services/DB/order_db.dart';


class Order extends StatefulWidget {
  const Order({Key? key}) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  Stream? order;

  @override
  void initState() {
    super.initState();
    getOrderData();
  }
  getOrderData()async{

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
        onTap: (){
      Navigator.pop(context);
    },
    child: const Icon(CupertinoIcons.back,color: Colors.white,),
    ),
    title: const Text("Order",style: TextStyle(color: Colors.white),),
    centerTitle: true,
    ),
      body: StreamBuilder(
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
                    return ListTile(
                      onTap: (){

                        },
                    );
                  });
            }else{
              return const Center(child: Text("Something Error"),);
            }
          }),
    );
  }
}
