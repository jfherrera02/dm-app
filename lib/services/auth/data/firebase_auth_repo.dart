
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dmessages/services/auth/domain/app_user.dart';
import 'package:dmessages/services/auth/repo/auth_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';

// implement the operations here
class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // used to save data to firestore
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // begin with loging (will replace old loging method)
  @override
  Future<AppUser?> newloginWithEmailPassword(String email, String password) async{
    try {
      // sign in attempt
      UserCredential newuserCredential = await firebaseAuth
      .signInWithEmailAndPassword(email: email, password: password);

      // create the user
      AppUser user = AppUser(
        uid: newuserCredential.user!.uid, 
        email: email, 
        username: '',
        );    
      // finally, return the user
      return user;
    }
    catch (e) {
      throw Exception("Login Failed: $e");
    }
  }

  // register user
  // NOTE: can be changed later for future app updates
  // such as adding 'current_country' 
  @override
  Future<AppUser?> newregisterWithEmailPassword(String name, String email, String password) async{
    try {
      // register attempt
      UserCredential newuserCredential = await firebaseAuth
      .createUserWithEmailAndPassword(email: email, password: password);

      // create the user
      AppUser user = AppUser(
        uid: newuserCredential.user!.uid, 
        email: email, 
        username: name,
        );
      
      // also save user data in firestore 
      await firebaseFirestore
      .collection("Users")
      .doc(user.uid).set(user.toJson());

      // finally, return the user
      return user;
    }
    catch (e) {
      throw Exception("Login Failed: $e");
    }
  }

  // logout current user
  @override
  Future<void> newlogout() async {
    firebaseAuth.signOut();
  }

  // fetch the current user
  @override
  Future<AppUser?> newgetCurrentUser() async {
    // get the current logged in user via firebase
    final firebaseUser = firebaseAuth.currentUser;

    // make sure it is not null (no user logged in)
    if (firebaseUser == null) {
      return null;
    }
    
      // user exists, so we fetch
      return AppUser(
        uid: firebaseUser.uid, 
        email: firebaseUser.email!, 
        username: '',
        );
  }
}