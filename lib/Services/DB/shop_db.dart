import 'package:cloud_firestore/cloud_firestore.dart';

class ShopDb{
  String id;
  ShopDb({required this.id});

  //Reference Collection
  final shopCollection=FirebaseFirestore.instance.collection("shop");

//
}