import 'package:firebase_auth/firebase_auth.dart';
import 'package:stock_management/Services/DB/user_db.dart';

import '../shared_preferences/spf.dart';

class Auth{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //Register
  Future<Object?> createUser(String email, String pass) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: pass))
          .user!;
      if (user.uid.isNotEmpty) {
        return true;
      }else{
        return false;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //login
  Future signInWithEmailAndPassword(String email, String pass) async {
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: pass))
          .user!;
      if (user.uid.isNotEmpty) {
        return true;
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //update password
  Future updateNewPass(String newPass) async {
    try {
      await firebaseAuth.currentUser!.updatePassword(newPass);
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  //signOut
  Future signOut() async {
    try {
      await SPF.saveUserLogInStatus(false);
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      return e;
    }
  }

  //reset password
  Future resetPassword(String email)async{
    firebaseAuth.setLanguageCode("en");
    try{
      await firebaseAuth.sendPasswordResetEmail(email: email);
    }on FirebaseAuthException catch(e){
      return e;
    }
  }

  //delete user
  Future deleteUser()async{
    try{
      UserDb(id: firebaseAuth.currentUser!.uid).deleteUser(true);
      await firebaseAuth.currentUser!.delete();
      return true;
    }on FirebaseAuthException catch(e){
      return e;
    }
  }
}