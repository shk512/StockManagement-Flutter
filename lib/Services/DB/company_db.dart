import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyDb{
  String id;
  CompanyDb({required this.id});

  //Reference Collection
  final companyCollection=FirebaseFirestore.instance.collection("company");

  //Get Company Data
  getData()async{
    return await companyCollection.doc(id).get();
  }

  //Update the Company Data
  Future updateCompany (Map<String,dynamic> mapData)async{
    await companyCollection.doc(id).update(mapData);
  }
}