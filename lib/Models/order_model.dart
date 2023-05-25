import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel{
 String _orderId="";
 String _orderBy="";
 String _deliverBy="";
 String _shopId="";
 String _shopDetails="";
 String _status="";
 String _remarks="";
 String _description="";
 String _dateTime="";
 List _products=[];
 num _totalAmount=0;
 num _advanceAmount=0;
 num _balanceAmount=0;
 num _concessionAmount=0;
 GeoPoint _location=GeoPoint(0,0);


  Map<String,dynamic> toJson(){
    return{
      "orderId": orderId,
      "orderBy": orderBy,
      "deliverBy": deliverBy,
      "shopId":shopId,
      "shopDetails":shopDetails,
      "status":status,
      "remarks":remarks,
      "description":description,
      "dateTime":dateTime,
      "products":products,
      "totalAmount":totalAmount,
      "advanceAmount":advanceAmount,
      "balanceAmount":balanceAmount,
      "concessionAmount":concessionAmount,
      "geoLocation": location
    };
  }

  fromJson(DocumentSnapshot snapshot){
    orderId=snapshot["orderId"];
    orderBy=snapshot["orderBy"];
    deliverBy=snapshot["deliverBy"];
    shopId=snapshot["shopId"];
    shopDetails=snapshot["shopDetails"];
    status=snapshot["status"];
    remarks=snapshot["remarks"];
    description=snapshot["description"];
    dateTime=snapshot["dateTime"];
    products=List.from(snapshot["products"]);
    totalAmount=snapshot["totalAmount"];
    advanceAmount=snapshot["advanceAmount"];
    concessionAmount=snapshot["concessionAmount"];
    balanceAmount=snapshot["balanceAmount"];
    location=snapshot["geoLocation"];
  }

 String get orderId => _orderId;

 set orderId(String value) {
   _orderId = value;
 }

 String get orderBy => _orderBy;

  set orderBy(String value) {
    _orderBy = value;
  }

 String get deliverBy => _deliverBy;

  set deliverBy(String value) {
    _deliverBy = value;
  }

 String get shopId => _shopId;

  set shopId(String value) {
    _shopId = value;
  }

 String get shopDetails => _shopDetails;

  set shopDetails(String value) {
    _shopDetails = value;
  }

 String get status => _status;

  set status(String value) {
    _status = value;
  }

 String get remarks => _remarks;

  set remarks(String value) {
    _remarks = value;
  }

 String get description => _description;

  set description(String value) {
    _description = value;
  }

 String get dateTime => _dateTime;

  set dateTime(String value) {
    _dateTime = value;
  }

 List get products => _products;

  set products(List value) {
    _products = value;
  }

 num get totalAmount => _totalAmount;

  set totalAmount(num value) {
    _totalAmount = value;
  }

 num get advanceAmount => _advanceAmount;

  set advanceAmount(num value) {
    _advanceAmount = value;
  }

 num get balanceAmount => _balanceAmount;

  set balanceAmount(num value) {
    _balanceAmount = value;
  }

 num get concessionAmount => _concessionAmount;

  set concessionAmount(num value) {
    _concessionAmount = value;
  }

 GeoPoint get location => _location;

  set location(GeoPoint value) {
    _location = value;
  }
}