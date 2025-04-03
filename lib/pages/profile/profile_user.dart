import 'package:dmessages/services/auth/domain/app_user.dart';

class ProfileUser extends AppUser {
  // new user info that we will change
  final String bio;
  final String profileImageUrl;

  // get all the data from the user 
  ProfileUser({
    required super.uid,
    required super.email,
    required super.username,
    required this.bio,
    required this.profileImageUrl,
  });

  // now we implement the method to update the profile user 
  ProfileUser copywith({String? newBio, String? newProfileImageUrl}) {
    return ProfileUser(
    uid: uid, 
    email: email, 
    username: username, 
    bio: newBio ?? bio, 
    profileImageUrl: newProfileImageUrl ?? profileImageUrl,
    );
  }

  // now we conver the format: profile user ----> json
  Map<String, dynamic> toJson(){
    return {
      'uid' : uid,
      'email' : email,
      'username' : username,
      'bio' : bio,
      'profileImageUrl' : profileImageUrl,
    };
  }

  // convert json format ---> app user  
  factory ProfileUser.fromJson(Map<String, dynamic> jsonUser) {
    return ProfileUser(
      uid: jsonUser['uid'], 
      email: jsonUser['email'],
      username: jsonUser['username'],
      bio: jsonUser['bio'] ?? '',
      profileImageUrl: jsonUser['profileImageUrl'] ?? '',
    );
  }
}