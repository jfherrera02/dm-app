import 'package:dmessages/services/auth/domain/app_user.dart';


// This will be a new method to obtain the user info in a cleaner way
// Shows what kind of operations are possible for this app
// Therfore, further operations can be implemented or deleted
abstract class AuthRepo {
  Future<AppUser?> newloginWithEmailPassword(String email, String password);
  Future<AppUser?> newregisterWithEmailPassword(
    String username, String email, String password, String country,
  );
  Future<void> newlogout();
  Future<AppUser?> newgetCurrentUser();
}