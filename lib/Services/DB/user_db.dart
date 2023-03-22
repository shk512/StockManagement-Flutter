import 'package:cloud_firestore/cloud_firestore.dart';

class UserDb{
  String id;
  UserDb({required this.id});

  //Reference Collection
  final userCollection=FirebaseFirestore.instance.collection("user");

  //get UserData
  getData()async{
    await userCollection.doc(id).get();
  }

  //save user
  Future saveUser(Map<String,dynamic> mapData)async{
    await userCollection.doc(id).set(mapData);
    return true;
  }
}