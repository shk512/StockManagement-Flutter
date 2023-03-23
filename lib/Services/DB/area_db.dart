import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stock_management/Services/DB/company_db.dart';

class AreaDB{
  String id;
  AreaDB({required this.id});

  //Reference
  final areaCollection=FirebaseFirestore.instance.collection("area");

  //save Area
  Future saveArea(Map<String,dynamic> mapData)async{
    await areaCollection.doc(id).set(mapData);
    return true;
  }

  //Get Area List
  getArea(){
    return areaCollection.snapshots();
  }

  //Delete Area
  Future deleteArea()async{
    await areaCollection.doc(id).delete();
    return true;
  }

}