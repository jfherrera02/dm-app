import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get the current user 
  // needed to check that user does not chat/interact with themselves + etc...
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  // sign in functionality
  Future<UserCredential> signinWithEmailPassword(String email, password) async{
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      // save the user information on a separate document for further use
      // save their information if it does not already exits when signing in  
        _firestore.collection("Users").doc(userCredential.user!.uid).set(
          {
            'uid': userCredential.user!.uid,
            'email': email,
          },
        );
    // end 
      return userCredential;

    } on FirebaseAuthException catch (e){
      throw Exception(e.code);
    }
  }

  // user sign up here
  Future<UserCredential> signInWithEmailAndPassword(String email, password, username) async {
    try{
      UserCredential userCredential = 
      await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password);

        // save the user information on a separate document for further use
        _firestore.collection("Users").doc(userCredential.user!.uid).set(
          {
            'uid': userCredential.user!.uid,
            'email': email,
            'username': username,
          },
        );

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