import 'package:cloud_firestore/cloud_firestore.dart';

class AuthDb{
  final String id="adminArray";

  //Reference Collection
  final companyArrayCollection=FirebaseFirestore.instance.collection("companyArray");

  //check license key
  Future<bool> licenseKey(String licenseId)async{
    DocumentSnapshot snapshot=await companyArrayCollection.doc(id).get();
    List<dynamic> check = await snapshot['companyId'];
    if (check.contains(licenseId)) {
      return true;
    } else {
      return false;
    }
  }
}