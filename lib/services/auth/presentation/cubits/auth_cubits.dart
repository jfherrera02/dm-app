// bloc implementation of authentication
import 'package:dmessages/services/auth/domain/app_user.dart';
import 'package:dmessages/services/auth/presentation/auth_states.dart';
import 'package:dmessages/services/auth/repo/auth_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthStates>{
  final AuthRepo authRepo;
  // keep track of the current user
  AppUser? _newcurrentUser; 

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  // steps for handling the user that is authenticated:
  // check if user is authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.newgetCurrentUser();

    // if it exists:
    if(user != null) {
      _newcurrentUser = user;
      // IMPORTANT
      // we must 'emit' the state for this to work
      emit(Authenticated(user));
    } else {
      emit(UnAuthenticated());
    }
  }

  // get the current user
  AppUser? get newgetCurrentUser => _newcurrentUser;

  // loging with the provided email and password
  Future<void> loging(String email, String password) async {
    try {
      emit(AuthLoading());
      final username = await authRepo.newloginWithEmailPassword(
        email, password);

      // keep tracking if there is a user 
      if (username != null) {
        _newcurrentUser = username;
        emit(Authenticated(username));
      }
      // otherwise
      else {
        emit(UnAuthenticated());
      }
      }
      catch (e) {
        // emit errors if any
        emit(AuthError(e.toString()));
        // which also means we are unauthenticated:
        emit(UnAuthenticated());
    }
    }
  

  // register with the provided information
  Future<void> newRegister(String userame, String email, String password, String country) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.newregisterWithEmailPassword(
        userame,
        email, password,
        country, // default to USA for now
      );
      // keep tracking if there is a user 
      if (user != null) {
        _newcurrentUser = user;
        emit(Authenticated(user));
      }
      // otherwise
      else {
        emit(UnAuthenticated());
      }
      }
      catch (e) {
        // emit errors if any
        emit(AuthError(e.toString()));
        // which also means we are unauthenticated:
        emit(UnAuthenticated());
    }
    }

  // logout
  Future<void> newlogout() async {
    authRepo.newlogout();
    emit(UnAuthenticated()); 
  }
}