import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyDb{
  String id;
  CompanyDb({required this.id});

  //Reference Collection
  final companyCollection=FirebaseFirestore.instance.collection("company");

  //Get Company Data
  Future getData()async{
    return await companyCollection.doc(id).get();
  }

  //update company wallet
  Future updateWallet(num amount)async{
    await companyCollection.doc(id).update({
      "wallet":FieldValue.increment(amount)
    });
  }

  //Update the Company Data
  Future updateCompany (Map<String,dynamic> mapData)async{
    await companyCollection.doc(id).update(mapData);
  }

}