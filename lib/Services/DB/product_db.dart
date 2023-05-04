import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDb{
  final String companyId;
  final String productId;
  ProductDb({required this.companyId,required this.productId});

  //Reference Collection
  final companyCollection=FirebaseFirestore.instance.collection("company");

  //save product
  Future saveProduct(Map<String,dynamic> mapData)async{
    await companyCollection.doc(companyId).collection("product").doc(productId).set(mapData);
    return true;
  }

  //update product
  Future updateProduct(Map<String,dynamic> mapData)async{
    await companyCollection.doc(companyId).collection("product").doc(productId).update(mapData);
    return true;
  }

  //update Stock
  Future updateStock(num quantity)async{
    await companyCollection.doc(companyId).collection("product").doc(productId).update({
      "totalQuantity": quantity
    });
    return true;
  }

  //add stock again
  Future updateStockAgain(num quantity)async{
   DocumentSnapshot snapshot= await companyCollection.doc(companyId).collection("product").doc(productId).get();
   quantity=snapshot["totalQuantity"]+quantity;
   updateStock(quantity);
  }

  //get Products
  Future getProducts() async{
    return companyCollection.doc(companyId).collection("product").snapshots();
  }

  //get product details
  Future getProductDetails()async{
    return await companyCollection.doc(companyId).collection("product").doc(productId).get();
  }

  //delete product
  Future deleteProduct()async{
    await companyCollection.doc(companyId).collection("product").doc(productId).update({
      "isDeleted":true
    });
    return true;
  }
}