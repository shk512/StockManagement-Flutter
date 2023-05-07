import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel{

  static Map<String,dynamic> toJson({
    required String productId,
    required String productName,
    required String description,
    required bool isDeleted,
    required num totalPrice,
    required num minPrice,
    required int quantityPerPiece,
    required int totalQuantity,
    required String imageUrl
}){
      return{
        "imageUrl":imageUrl,
        "productId":productId,
        "productName":productName,
        "description":description,
        "totalPrice":totalPrice,
        "minPrice":minPrice,
        "quantityPerPiece":quantityPerPiece,
        "totalQuantity":totalQuantity,
        "isDeleted":isDeleted
      };
  }

}