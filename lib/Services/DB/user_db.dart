import 'package:cloud_firestore/cloud_firestore.dart';

class UserDb{
  String id;
  UserDb({required this.id});

  //Reference Collection
  final userCollection=FirebaseFirestore.instance.collection("user");

  //Get ALl users
  Future getAllUser()async{
    return userCollection.snapshots();
  }

  //get UserData
  Future getData()async{
    return await userCollection.doc(id).get();
  }

  //save user
  Future saveUser(Map<String,dynamic> mapData)async{
    await userCollection.doc(id).set(mapData);
  }

  //delete User
  Future deleteUser()async{
    await userCollection.doc(id).update({
      "isDeleted":true
    });
  }

  //update user
  Future updateUser(Map<String,dynamic> mapData)async{
    await userCollection.doc(id).update(mapData);
  }

  //update user wallet
  Future updateWalletBalance(num amount)async{
    await userCollection.doc(id).update({
      "wallet":FieldValue.increment(amount)
    });
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
      userCollection.doc(id).update({
        "area":FieldValue.arrayRemove([area]),
      });
      return true;
    }else{
      return false;
    }
  }

  //get area list
  Future getAreaList()async{
    DocumentSnapshot snapshot=await userCollection.doc(id).get();
    return await snapshot["area"];
  }
}