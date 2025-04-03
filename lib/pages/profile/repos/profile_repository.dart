// Define all the different operations we can do for the user profile

import 'package:dmessages/pages/profile/profile_user.dart';

abstract class ProfileRepository {
  Future<ProfileUser?> fetchUserProfile(String uid);
  
  // update the profile
  Future<void> updateProfile (ProfileUser updateProfile);
}