import 'package:cloud_firestore/cloud_firestore.dart';

class AreaDb{
  final companyId;
  final areaId;

  AreaDb({required this.areaId, required this.companyId});

  //reference collection
  final companyCollection=FirebaseFirestore.instance.collection("company");

  //save area
  Future saveArea(Map<String, dynamic>mapData)async{
    await companyCollection.doc(companyId).collection("area").doc(areaId).set(mapData);
    return true;
  }

  //getArea
  Future getArea()async{
    return await companyCollection.doc(companyId).collection("area").where("isDeleted", isEqualTo: false).snapshots();
  }

  //get total area count
  Future getAreaCounts()async{
    return await companyCollection.doc(companyId).collection("area").count().get();
  }

  //get area by id
  Future getAreaById()async{
    return await companyCollection.doc(companyId).collection("area").doc(areaId).get();
  }

  //delete area
  Future deleteArea()async{
    await companyCollection.doc(companyId).collection("area").doc(areaId).update({
          "isDeleted":true
        });
  }

  //update Area
  Future updateArea(String areaName)async{
    await companyCollection.doc(companyId).collection("area").doc(areaId).update({
      "areaName":areaName
    });
  }
}