

// This file will serve as the heart of the logic that 
// will handle the user data for cleaner use
// Implemented 3/31/25 - Several Updates inital app creation

class AppUser {
  final String uid;
  final String username;
  final String email;
  final String country; // not used yet

  // require the constructor to have these fields when creating the user
  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.country,
  });

  // 2 helper methods
  // convert app user --> json
  Map<String, dynamic> toJson(){
    return {
      'uid' : uid,
      'email' : email,
      'username' : username,
      'country' : country,
    };
  }

  // convert json format ---> app user  
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'], 
      email: jsonUser['email'],
      username: jsonUser['username'],
      country: jsonUser['country'] ?? '', // default to empty string if not present
    );
  }
}