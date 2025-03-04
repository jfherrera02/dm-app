import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // sign in functionality
  Future<UserCredential> signinWithEmailPassword(String email, password) async{
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential;

    } on FirebaseAuthException catch (e){
      throw Exception(e.code);
    }
  }

  // user sign up here
  Future<UserCredential> signInWithEmailAndPassword(String email, password) async {
    try{
      UserCredential userCredential = 
      await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password);
        // finish
        return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // method to sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
}