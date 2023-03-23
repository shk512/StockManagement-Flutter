

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDB{
  String id;
  OrderDB({required this.id});

  //Reference
  final orderCollerction=FirebaseFirestore.instance.collection("order");

  //Get All Orders
  getOrder(){
    return orderCollerction.orderBy("date",descending: true).snapshots();
  }

  //save Order
  Future saveOrder(Map<String,dynamic> mapData)async{
    await orderCollerction.doc(id).set(mapData);
    return true;
  }

  //get Order By Id
  getOrderById()async{
    return await orderCollerction.doc(id).get();
  }
}