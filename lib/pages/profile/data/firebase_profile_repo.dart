import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dmessages/pages/profile/profile_user.dart';
import 'package:dmessages/pages/profile/repos/profile_repository.dart';

class FirebaseProfileRepo implements ProfileRepository{
  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      // obtain user data document from firestore
      final userDocument = 
      await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      // make sure the user exists

      if (userDocument.exists) {
        final userData = userDocument.data();

        if (userData != null) {
          return ProfileUser(
            uid: uid, 
            email: userData['email'], 
            username: userData['username'], 
            bio: userData['bio'] ?? '', // bio can be null so give ''
            profileImageUrl: userData['profileImageUrl'].toString(),
            country: userData['country'] ?? '', // default to empty string if not present
            );
        }
      }
      
      // otherwise we return null
      return null;
    }
    catch (e) {
      return null;
    }
  }
  
  @override
  Future<void> updateProfile(ProfileUser updateProfile) async {
    // convert the updated profile into a json format here:
    // then we can store it in firebase

    try{
      await FirebaseFirestore.instance
      .collection('Users')
      .doc(updateProfile.uid)
      .update({
        'bio' : updateProfile.bio,
        'profileImageUrl' : updateProfile.profileImageUrl,
      });
    } catch (e) {
      throw Exception(e); 
    }
  }
}