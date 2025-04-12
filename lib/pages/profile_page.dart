import 'package:cached_network_image/cached_network_image.dart';
import 'package:dmessages/components/bio.dart';
import 'package:dmessages/pages/profile/edit_profile.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_cubit.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_states.dart';
import 'package:dmessages/services/auth/domain/app_user.dart';
import 'package:dmessages/services/auth/presentation/cubits/auth_cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfilePage extends StatefulWidget {
  // Allow other users to view current profile: 
  // REQUIRE 1 thing (NEW) implementation
  // uid
  final String uid; 
  const UserProfilePage({super.key, required this.uid});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // read in the cubits
  late final authCubit = context.read<AuthCubit> ();
  late final profileCubit = context.read<ProfileCubit>(); 

  // get the current user
  late AppUser? currentUser = authCubit.newgetCurrentUser;

  @override
  void initState() {
    super.initState();

    // then load in the user profile data to show
    profileCubit.fetchUserProfile(widget.uid);
  }

  // begin making the UI for the profile page
  @override
  Widget build(BuildContext context) {
    // use a bloc builder to provide the state of the profile and cubit 
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        // different states:
        // loaded
        if (state is ProfileLoaded) {
          // retrieve the loaded user now 
          final user = state.profileUser;
          debugPrint('Loaded profileImageUrl: ${user.profileImageUrl}');
          // Evict cache for the profile image to ensure a fresh download.
          Future.delayed(Duration.zero, () {
            CachedNetworkImage.evictFromCache(user.profileImageUrl);
          });
          return Scaffold(
            appBar: AppBar(
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                // create an 'edit profile' button
                IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      // go to the edit profile page when clicking button
                      builder: (context) => EditProfile(user: user),
                    )
                  ), 
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            // body
            body: Center(
              child: Column(
                children: [
                  // username 
                  Text(
                    user.username,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary
                    ),
                  ),
                  
                  // spacing 
                  const SizedBox(height: 20),
                  // followed by the profile picture:

                  // THIS IS CRUCIAL ->
                  // use the cached network image to load the profile image
                  // and cache it for later use
                  // (before implementing this, the profile image was not loading)
                  // but it was already in the database
                  // and the url was correct
                  CachedNetworkImage(
                    key: ValueKey(user.profileImageUrl), // forces a rebuild when URL changes
                    imageUrl: user.profileImageUrl,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) {
                      debugPrint("Error loading image: $error");
                      return Icon(
                        Icons.person,
                        size: 68,
                        color: Theme.of(context).colorScheme.primary,
                      );
                    },
                    imageBuilder: (context, imageProvider) => Container(
                      width: 150,  // provide explicit width
                      height: 150, // provide explicit height
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // end of profile image
                  // bio display
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "Bio",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                    ],
                  ),
                  Bio(text: user.bio),
                ],
              ),
            )
          );
        }

        // loading.... state ->
        else if(state is ProfileLoading){
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const Center(
            child: Text("No Profile was found."),
          );
        }
      },
    );
  }
}
