import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel{
  static String productId='';
  static String productName='';
  static String description='';
  static num totalPrice=0;
  static num minPrice=0;
  static int quantityPerPiece=0;
  static int totalQuantity=0;
  static bool isDeleted=false;

  static Map<String,dynamic> toJson({
    required String productId,
    required String productName,
    required String description,
    required bool isDeleted,
    required num totalPrice,
    required num minPrice,
    required int quantityPerPiece,
    required int totalQuantity
}){
      return{
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

  static fromJson(DocumentSnapshot snapshot){
    productId=snapshot["productId"];
    productName=snapshot["productName"];
    description=snapshot["description"];
    totalPrice=snapshot["totalPrice"];
    minPrice=snapshot["minPrice"];
    isDeleted=snapshot["isDeleted"];
    quantityPerPiece=snapshot["quantityPerPiece"];
    totalQuantity=snapshot["totalQuantity"];
  }
}