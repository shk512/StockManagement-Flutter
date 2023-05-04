

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDB{
  String companyId;
  String orderId;
  OrderDB({required this.companyId,required this.orderId});

  //Reference
  final companyCollection=FirebaseFirestore.instance.collection("company");

  //Get All Orders
  getOrder(){
    return companyCollection.doc(companyId).collection("order").orderBy("date",descending: true).snapshots();
  }

  //save Order
  Future saveOrder(Map<String,dynamic> mapData)async{
    await companyCollection.doc(companyId).collection("order").doc(orderId).set(mapData);
    return true;
  }

  //get Order By Id
  getOrderById()async{
    return await companyCollection.doc(companyId).collection("order").doc(orderId).get();
  }
}