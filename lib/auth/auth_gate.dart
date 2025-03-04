import 'package:dmessages/auth/login_or_register.dart';
import 'package:dmessages/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


// constanly listens to the authentication (auth) stage
// to determine if user = signed in/out
class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          // check that user is logged in
          if (snapshot.hasData) {
            return const HomePage();
          }
          // NOT logged in then ->
          else{
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}