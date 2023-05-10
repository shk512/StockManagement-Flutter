

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDB{
  String companyId;
  String orderId;
  OrderDB({required this.companyId,required this.orderId});

  //Reference
  final companyCollection=FirebaseFirestore.instance.collection("company");

  //Get All Orders
  Future getOrder()async{
    return companyCollection.doc(companyId).collection("order").orderBy("dateTime",descending: true).snapshots();
  }

  //save Order
  Future saveOrder(Map<String,dynamic> mapData)async{
    await companyCollection.doc(companyId).collection("order").doc(orderId).set(mapData);
    return true;
  }

  //update Order
  Future updateOrder(Map<String,dynamic> mapData)async{
    await companyCollection.doc(companyId).collection("order").doc(orderId).update(mapData);
    return true;
  }

  //get Order By Id
  Future getOrderById()async{
    return companyCollection.doc(companyId).collection("order").doc(orderId).get();
  }
}