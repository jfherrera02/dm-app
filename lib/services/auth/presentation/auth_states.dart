// manange the authentication states:
// different steps and processes of a user signing up/ logging in

import 'package:dmessages/services/auth/domain/app_user.dart';

abstract class AuthStates {}

// initial state 
class AuthInitial extends AuthStates {}

// loading.... state
class AuthLoading extends AuthStates {}

// authenticated state
class Authenticated extends AuthStates {
  // have the logged in user 
  final AppUser user; 
  Authenticated(this.user);
}

// unauthenticated state
class UnAuthenticated extends AuthStates {}

// errors ---> 
class AuthError extends AuthStates {
  final String message; 
  AuthError(this.message);
}