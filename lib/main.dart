import 'package:dmessages/calendar/data/calendar_repository.dart';
import 'package:dmessages/calendar/domain/calendar_cubit.dart';
import 'package:dmessages/features/data/firebase_storage_repository.dart';
import 'package:dmessages/post/presentation/pages/actual_home.dart';
import 'package:dmessages/pages/profile/data/firebase_profile_repo.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_cubit.dart';
import 'package:dmessages/post/data/firebase_post_repo.dart';
import 'package:dmessages/post/presentation/cubits/post_cubit.dart';
import 'package:dmessages/services/auth/auth_gate.dart';
import 'package:dmessages/firebase_options.dart';
import 'package:dmessages/services/auth/data/firebase_auth_repo.dart';
import 'package:dmessages/services/auth/presentation/auth_states.dart';
import 'package:dmessages/services/auth/presentation/cubits/auth_cubits.dart';
import 'package:dmessages/themes/theme_cubit.dart';
import 'package:dmessages/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // load the env variables
  // will default to .env file in the root of the project
  await dotenv.load(fileName: "assets/.env");
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      // old implementation was:
      // child: const MyApp();
      child: MyApp(),
    ),
  );
}

//
class MyApp extends StatelessWidget {
  // auth repository
  final authRepo = FirebaseAuthRepo();
  // repo that holds profile images from firabase storage
  final storageRepository = FirebaseStorageRepository();

  // post repository
  // this is the repository that will be used to upload the post to the backend
  final postRepository = FirebasePostRepo();

  // create firebase repo for Profile provider
  final profileRepository = FirebaseProfileRepo();

  // get the new calendar repository
  final calendarRepository = CalendarRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // providing the cubits to our app
    return MultiBlocProvider(
      providers: [
        // provide all of the cubits:
        // auth cubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepo: authRepo)..checkAuth(),
        ),

        // profile cubit provider
        BlocProvider<ProfileCubit>(
          // requires a firebase repo
          create: (context) => ProfileCubit(
            profileRepository: profileRepository,
            storageRepository: storageRepository,
          ),
        ),
        // post cubit provider
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepo: postRepository,
            storageRepo: storageRepository,
          ),
        ),
        // theme cubit
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, currentTheme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: currentTheme,
            // checks current auth state
            home: BlocConsumer<AuthCubit, AuthStates>(
              builder: (context, authStates) {
                // unath -> go to login/register
                if (authStates is UnAuthenticated) {
                  return AuthGate();
                }

                // authenticated -> go to the home page
                if (authStates is Authenticated) {
                  return BlocProvider<CalendarCubit>(
                    create: (context) => CalendarCubit(
                      calendarId: authStates.user.uid,
                      repository: calendarRepository,
                    ),
                    child: const ActualHome(),
                  );
                }

                // loading...
                else {
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
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
            ),
          );
        },
      ),
    );
  }
}
