import 'package:cloud_firestore/cloud_firestore.dart';

class AccountDb{
  final companyId;
  final transactionId;
  AccountDb({required this.companyId,required this.transactionId});

  //Reference Collection
  final companyCollection=FirebaseFirestore.instance.collection("company");

  //save Transaction
  Future saveTransaction(Map<String, dynamic> mapData)async{
    await companyCollection.doc(companyId).collection("transaction").doc(transactionId).set(mapData);
    return true;
  }

  //Get All transactions
  Future getTransaction()async{
    return await companyCollection.doc(companyId).collection("transaction").snapshots();
  }

  //Get Transaction Details
  Future getTransactionDetail()async{
    return await companyCollection.doc(companyId).collection("transaction").doc(transactionId).get();
  }
}