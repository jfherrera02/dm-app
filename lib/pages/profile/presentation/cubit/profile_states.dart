// track the profile states
import 'package:dmessages/pages/profile/profile_user.dart';

abstract class ProfileStates {}

// initial state
class ProfileInitial extends ProfileStates{}

// loading... state
class ProfileLoading extends ProfileStates{}


// loaded state
class ProfileLoaded extends ProfileStates{
  // if the profile is loaded ----> store it
  final ProfileUser profileUser;
  ProfileLoaded(this.profileUser);
}

// errors
class ProfileError extends ProfileStates{
  // same as loaded but use message
  final String message;
  ProfileError(this.message);
}
