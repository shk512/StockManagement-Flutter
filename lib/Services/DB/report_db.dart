import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDb{
  final String companyId;
  final String productId;
  ReportDb({required this.companyId,required this.productId});

  //Reference Collection
  final companyCollection=FirebaseFirestore.instance.collection("company");

  //increment report
  Future increment(num quantity, String date) async{
    await companyCollection.doc(companyId).collection("report").doc(productId).set({
      "productId":productId,
      "$date": FieldValue.increment(quantity),
    });
    return true;
  }

  //decrement report
  Future decrement(num quantity,String date)async{
    await companyCollection.doc(companyId).collection("report").doc(productId).update({
      "productId":productId,
      "$date":FieldValue.increment(-quantity),
    });
    return true;
  }
}