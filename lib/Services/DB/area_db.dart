import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_management/Services/DB/company_db.dart';

class AreaDB{
  String id;
  AreaDB({required this.id});

  //Reference
  final companyAreaCollection=FirebaseFirestore.instance.collection("company");
  final userAreaCollection=FirebaseFirestore.instance.collection("user");

  //save Company Area
  Future<bool?> saveArea(String area)async{
    DocumentSnapshot snapshot=await companyAreaCollection.doc(id).get();
    List check=await snapshot["area"];
    if(check.contains(area)){
      return false;
    }else{
      companyAreaCollection.doc(id).update({
        "area":FieldValue.arrayUnion([area]),
      });
      return true;
    }
  }

  //Delete Company Area
  Future deleteArea(String area)async{
    DocumentSnapshot snapshot=await companyAreaCollection.doc(id).get();
    List check=await snapshot["area"];
    if(check.contains(area)){
      return false;
    }else{
      companyAreaCollection.doc(id).update({
        "area":FieldValue.arrayRemove([area]),
      });
      return true;
    }
  }

  //Save User Area
  Future<bool?> saveUserArea(String area)async{
    DocumentSnapshot snapshot=await userAreaCollection.doc(id).get();
    List check=await snapshot["area"];
    if(check.contains(area)){
      return false;
    }else{
      companyAreaCollection.doc(id).update({
        "area":FieldValue.arrayUnion([area]),
      });
      return true;
    }
  }

  //Delete Company Area
  Future deleteUserArea(String area)async{
    DocumentSnapshot snapshot=await userAreaCollection.doc(id).get();
    List check=await snapshot["area"];
    if(check.contains(area)){
      return false;
    }else{
      companyAreaCollection.doc(id).update({
        "area":FieldValue.arrayRemove([area]),
      });
      return true;
    }
  }

}