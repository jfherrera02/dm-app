import 'package:dmessages/pages/register_page.dart';
import 'package:dmessages/themes/light_mode.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'auth/login_or_register.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner:false,
      home: LoginOrRegister(),
      theme: lightmode, // run light mode
    );
  }
}
