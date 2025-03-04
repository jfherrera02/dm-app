import 'package:dmessages/auth/auth_gate.dart';
import 'package:dmessages/firebase_options.dart';
import 'package:dmessages/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'auth/login_or_register.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner:false,
      home: const        AuthGate(),
      theme: lightmode, // run light mode
    );
  }
}
