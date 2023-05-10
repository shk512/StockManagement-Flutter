import 'package:cloud_firestore/cloud_firestore.dart';

class ShopDB{
  final String shopId;
  final String companyId;
  ShopDB({required this.companyId,required this.shopId});

  //Reference Collection
  final companyCollection=FirebaseFirestore.instance.collection("company");

  //Save Shop
  Future saveShop(Map<String,dynamic> mapData)async{
    await companyCollection.doc(companyId).collection("shop").doc(shopId).set(mapData);
  }

  //Get Shops
  Future getShops()async{
    return companyCollection.doc(companyId).collection("shop").snapshots();
  }

  //Get shop details
  Future getShopDetails() async{
    return companyCollection.doc(companyId).collection("shop").doc(shopId).get();
  }

  //update shopData
  Future updateShop(Map<String,dynamic> mapData)async{
    await companyCollection.doc(companyId).collection("shop").doc(shopId).update(mapData);
    return true;
  }

  //update wallet
  Future updateWallet(num amount) async{
    await companyCollection.doc(companyId).collection("shop").doc(shopId).update({
      "wallet":FieldValue.increment(amount)
    });
  }

  //Delete Shop
  Future deleteShop()async {
    await companyCollection.doc(companyId).collection("shop")
        .doc(shopId)
        .update({"isDeleted":true});
    return true;
  }
}