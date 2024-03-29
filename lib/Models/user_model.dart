
class UserModel{
  String _userId="";
  String _designation="";
  String _companyId="";
  String _name="";
  String _mail="";
  String _phone="";
  String _role="";
  num _wallet=0;
  num _salary=0;
  List _area=[];
  List _rights=[];
  bool _isDeleted=false;

  Map<String,dynamic> toJson(
  {
    required String userId,
    required String name,
    required num salary,
    required String mail,
    required String companyId,
    required String phone,
    required String role,
    required String designation,
    required num wallet,
    required bool isDeleted,
    required List rights,
    required List area
    }){
    return {
      "userId":userId,
      "name":name,
      "salary":salary,
      "mail":mail,
      "companyId":companyId,
      "phone":phone,
      "role":role,
      "designation":designation,
      "wallet":wallet,
      "isDeleted":isDeleted,
      "right":rights,
      "area":area
    };
  }

  String get userId => _userId;

  set userId(String value) {
    _userId = value;
  }

  String get designation => _designation;

  set designation(String value) {
    _designation = value;
  }

  String get companyId => _companyId;

  set companyId(String value) {
    _companyId = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get mail => _mail;

  set mail(String value) {
    _mail = value;
  }

  String get phone => _phone;

  set phone(String value) {
    _phone = value;
  }

  String get role => _role;

  set role(String value) {
    _role = value;
  }

  num get wallet => _wallet;

  set wallet(num value) {
    _wallet = value;
  }

  num get salary => _salary;

  set salary(num value) {
    _salary = value;
  }

  List get area => _area;

  set area(List value) {
    _area = value;
  }

  List get rights => _rights;

  set rights(List value) {
    _rights = value;
  }

  bool get isDeleted => _isDeleted;

  set isDeleted(bool value) {
    _isDeleted = value;
  }
}