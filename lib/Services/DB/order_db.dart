

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDB{
  String id;
  OrderDB({required this.id});

  //Reference
  final companyCollerction=FirebaseFirestore.instance.collection("company");

  //Get All Orders
  getOrder(){
    return companyCollerction.orderBy("date",descending: true).snapshots();
  }

  //save Order
  Future saveOrder(Map<String,dynamic> mapData)async{
    await companyCollerction.doc(id).set(mapData);
    return true;
  }

  //get Order By Id
  getOrderById()async{
    return await companyCollerction.doc(id).get();
  }
}