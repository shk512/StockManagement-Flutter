import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel{

  String _productId="";
  String _productName="";
  String _description="";
  String _imageUrl="";
  bool _isDeleted=false;
  num _totalPrice=0;
  num _minPrice=0;
  int _totalQuantity=0;
  int _quantityPerPiece=0;


  Map<String,dynamic> toJson(){
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

  fromJson(DocumentSnapshot snapshot){
    imageUrl=snapshot["imageUrl"];
    productId=snapshot["productId"];
    productName=snapshot["productName"];
    description=snapshot["description"];
    totalPrice=snapshot["totalPrice"];
    minPrice=snapshot["minPrice"];
    quantityPerPiece=snapshot["quantityPerPiece"];
    totalQuantity=snapshot["totalQuantity"];
    isDeleted=snapshot["isDeleted"];
  }


  String get productId => _productId;

  set productId(String value) {
    _productId = value;
  }

  String get productName => _productName;

  set productName(String value) {
    _productName = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }

  String get imageUrl => _imageUrl;

  set imageUrl(String value) {
    _imageUrl = value;
  }

  bool get isDeleted => _isDeleted;

  set isDeleted(bool value) {
    _isDeleted = value;
  }

  num get totalPrice => _totalPrice;

  set totalPrice(num value) {
    _totalPrice = value;
  }

  num get minPrice => _minPrice;

  set minPrice(num value) {
    _minPrice = value;
  }

  int get totalQuantity => _totalQuantity;

  set totalQuantity(int value) {
    _totalQuantity = value;
  }

  int get quantityPerPiece => _quantityPerPiece;

  set quantityPerPiece(int value) {
    _quantityPerPiece = value;
  }
}