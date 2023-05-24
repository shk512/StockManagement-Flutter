

import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDb{
  final String companyId;
  final String productId;
  ReportDb({required this.companyId,required this.productId});

  //Reference Collection
  final companyCollection=FirebaseFirestore.instance.collection("company");

  //increment report
  Future increment(num quantity, String date) async{
    await companyCollection.doc(companyId).collection("report").doc(date).update({
      "$productId":FieldValue.increment(quantity),
    }).onError((error, stackTrace)async{
      await companyCollection.doc(companyId).collection("report").doc(date).set({
        "$productId":quantity,
        "date":date
      });
    });
    return true;
  }

  //decrement report
  Future decrement(num quantity,String date)async{
    await companyCollection.doc(companyId).collection("report").doc(date).update({
      "$productId":FieldValue.increment(-quantity),
    });
    return true;
  }

  //GET REPORT
  Future getReport()async{
    return await companyCollection.doc(companyId).collection("report").orderBy("date", descending: true).snapshots();
  }
}