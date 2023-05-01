import 'package:cloud_firestore/cloud_firestore.dart';

class UserDb{
  String id;
  UserDb({required this.id});

  //Reference Collection
  final userCollection=FirebaseFirestore.instance.collection("user");

  //Get ALl users
  getAllUser(){
    return userCollection.orderBy("role",descending: false).snapshots();
  }

  //get UserData
  getData()async{
    return await userCollection.doc(id).get();
  }

  //save user
  Future saveUser(Map<String,dynamic> mapData)async{
    await userCollection.doc(id).set(mapData);
  }

  //update area list
  Future updateAreaList(String areaName) async{
    DocumentSnapshot snapshot=await userCollection.doc(id).get();
    List check=await snapshot["area"];
    if(check.contains(areaName)){
      return false;
    }else{
      userCollection.doc(id).update({
        "area":FieldValue.arrayUnion([areaName]),
      });
      return true;
    }
  }

  //Delete user Area
  Future deleteUserArea(String area)async{
    DocumentSnapshot snapshot=await userCollection.doc(id).get();
    List check=await snapshot["area"];
    if(check.contains(area)){
      return false;
    }else{
      userCollection.doc(id).update({
        "area":FieldValue.arrayRemove([area]),
      });
      return true;
    }
  }

  //get area list
  getAreaList()async{
    DocumentSnapshot snapshot=await userCollection.doc(id).get();
    return await snapshot["area"];
  }
}