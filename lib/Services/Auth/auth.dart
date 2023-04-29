import 'package:firebase_auth/firebase_auth.dart';

import '../shared_preferences/spf.dart';

class Auth{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //Register
  Future<Object?> createUser(String email, String pass) async {
    try {
      User user = (await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: pass))
          .user!;
      if (user != null) {
        return true;
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
      if (user != null) {
        return "true";
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future updateNewPass(String newPass) async {
    try {
      await firebaseAuth.currentUser?.updatePassword(newPass);
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
    } catch (e) {
      return e;
    }
  }

  //DELETE
  Future deleteUser() async {
    try {
      await firebaseAuth.currentUser!.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}