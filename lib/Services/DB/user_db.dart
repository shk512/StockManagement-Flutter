import 'package:cloud_firestore/cloud_firestore.dart';

class UserDb{
  String id;
  UserDb({required this.id});

  //Reference Collection
  final userCollection=FirebaseFirestore.instance.collection("user");

  //Get ALl users
  getAllUser(){
    return userCollection.snapshots();
  }

  //get UserData
  getData()async{
    return await userCollection.doc(id).get();
  }

  //save user
  Future saveUser(Map<String,dynamic> mapData)async{
    await userCollection.doc(id).set(mapData);
    return true;
  }
}