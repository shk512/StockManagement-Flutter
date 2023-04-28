import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:stock_management/Models/shop_model.dart';

class ShopDB{
  String id;
  ShopDB({required this.id});

  //Reference Collection
  final shopCollection=FirebaseFirestore.instance.collection("shop");

  //Save Shop
  Future saveShop(Map<String,dynamic> mapData)async{
    await shopCollection.doc(id).set(mapData);
  }

  //Get Shops
  getShops(){
    return shopCollection.snapshots();
  }

  //Delete Shop
  Future deleteShop()async{
    await shopCollection.doc(id).delete();
    return true;
  }
}