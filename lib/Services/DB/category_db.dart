import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryDb{
  String id;
  CategoryDb({required this.id});

  //Reference Collection
  final categoryCollection=FirebaseFirestore.instance.collection("category");

  //
}