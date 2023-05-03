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

  //save Company Area
  Future saveArea(String area)async{
    DocumentSnapshot snapshot=await companyCollection.doc(id).get();
    List check=await snapshot["area"];
    if(check.contains(area)){
      return false;
    }else{
      companyCollection.doc(id).update({
        "area":FieldValue.arrayUnion([area]),
      });
      return true;
    }
  }

  //Delete Company Area
  Future deleteArea(String area)async{
    DocumentSnapshot snapshot=await companyCollection.doc(id).get();
    List check=await snapshot["area"];
    if(check.contains(area)){
      companyCollection.doc(id).update({
        "area":FieldValue.arrayRemove([area]),
      });
      return true;
    }else{
      return false;
    }
  }

}