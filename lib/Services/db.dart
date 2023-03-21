import 'package:cloud_firestore/cloud_firestore.dart';

class DB{
  String id;
  DB({required this.id});

  //Reference Collection
  final companyCollection=FirebaseFirestore.instance.collection("company");
  final companyArrayCollection=FirebaseFirestore.instance.collection("companyArray");
  final userCollection=FirebaseFirestore.instance.collection("user");
  final shopCollection=FirebaseFirestore.instance.collection("shop");
  final categoryCollection=FirebaseFirestore.instance.collection("category");

  //
}