import 'package:dmessages/pages/actual_home.dart';
import 'package:dmessages/services/auth/auth_gate.dart';
import 'package:dmessages/firebase_options.dart';
import 'package:dmessages/services/auth/data/firebase_auth_repo.dart';
import 'package:dmessages/services/auth/presentation/auth_states.dart';
import 'package:dmessages/services/auth/presentation/cubits/auth_cubits.dart';
import 'package:dmessages/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      // old implementation was:
      // child: const MyApp();
      child: MyApp(),
      ),
    );
}
/* OLD IMPLEMENTATION - PRE BLOC
class MyApp extends StatelessWidget{
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner:false,
      home: const AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData, // run light mode
    );
  }
}

*/

// Bloc Implementation: 
// Initialize database repos for firebase 
// Bloc Providers- auth, profile, post, search, theme?, etc
// check authentication states 
// unauth -> auth page (login/register)
// authenticated -> home page

class MyApp extends StatelessWidget{
  // auth repository 
  final authRepo = FirebaseAuthRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // providing the cubit to our app
    return BlocProvider(create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
    child: MaterialApp(
      debugShowCheckedModeBanner: true,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: BlocConsumer<AuthCubit, AuthStates>(
        builder: (context, authStates) {
          print(authStates);
          // unath -> go to login/register
          if(authStates is UnAuthenticated) {
            return AuthGate();
          }

          // authenticated -> go to the home page
          if(authStates is Authenticated) {
            return const ActualHome();
          }

          // loading... 
          else{
            return const Scaffold(
              // loading circle 
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }, 

        // check for any possible errors
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger
            .of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        ),
    )
    );
  }
}