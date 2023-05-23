

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDB{
  String companyId;
  String orderId;
  OrderDB({required this.companyId,required this.orderId});

  //Reference
  final companyCollection=FirebaseFirestore.instance.collection("company");

  //Get All Orders
  Future getOrder()async{
    return await companyCollection.doc(companyId).collection("order").orderBy("dateTime",descending: true).snapshots();
  }

  //get process order
  Future getProcessOrder()async{
    return await companyCollection.doc(companyId).collection("order").where("status", isEqualTo: "PROCESSING").snapshots();
  }

  //get dispatch order
  Future getDispatchOrder()async{
    return await companyCollection.doc(companyId).collection("order").where("status", isEqualTo: "DISPATCH").snapshots();
  }

  //get deliver order
  Future getDeliverOrder()async{
    return await companyCollection.doc(companyId).collection("order").where("status", isEqualTo: "DELIVER").snapshots();
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

  //process order counts
  Future<int> getProcessOrderCounts()async{
    return await companyCollection.doc(companyId).collection("order").where("status", isEqualTo:"PROCESSING").snapshots().length;
  }

  //process order counts
  Future<int> getDispatchOrderCounts()async{
    return await companyCollection.doc(companyId).collection("order").where("status", isEqualTo:"DISPATCH").snapshots().length;
  }

  //process order counts
  Future<int> getDeliverOrderCounts()async{
    return await companyCollection.doc(companyId).collection("order").where("status", isEqualTo:"DELIVER").snapshots().length;
  }

  //process order counts
  Future<int> getAllOrderCounts()async{
    return await companyCollection.doc(companyId).collection("order").snapshots().length;
  }
}