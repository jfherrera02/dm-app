import 'package:cached_network_image/cached_network_image.dart';
import 'package:dmessages/components/bio.dart';
import 'package:dmessages/pages/profile/edit_profile.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_cubit.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_states.dart';
import 'package:dmessages/post/presentation/cubits/post_cubit.dart';
import 'package:dmessages/post/presentation/cubits/post_states.dart';
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
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  // get the current user
  late AppUser? currentUser = authCubit.newgetCurrentUser;

  // track the number of posts
  int postCount = 0;

  // track the number of friends
  int friendCount = 0;

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
              // show the user's country flag or default if not available
              title: user.country.isNotEmpty
              ? Text(user.country, style: const TextStyle(fontSize: 18))
              : const Icon(Icons.flag, size: 24),
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
            // Use SingleChildScrollView to enable scrolling for a clean Instagram-like layout
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top profile header section similar to Instagram
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        /*
                        // show the user's country flag or default if not available
                        if (user.country != '' && user.country.isNotEmpty)
                          Text(user.country, style: const TextStyle(fontSize: 24)) // show country flag if available
                        else
                          const Icon(Icons.flag, size: 24), // default icon if no flag URL
                        */
                        // profile image on left
                        
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
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // statistics: posts, followers, following
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // posts count
                              Column(
                                children: [
                                  Text(
                                    '$postCount',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Posts'),
                                ],
                              ),
                              // friends count as placeholder for followers
                              Column(
                                children: [
                                  Text(
                                    '$friendCount',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Followers'),
                                ],
                              ),
                              // For simplicity, duplicating friendCount for "Following"
                              Column(
                                children: [
                                  Text(
                                    '$friendCount',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Following'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Display username and bio similar to Instagram profile header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // username 
                        Text(
                          user.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // bio display
                        Bio(text: user.bio),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  
                  // Show user posts in a grid similar to Instagram's post grid
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: BlocBuilder<PostCubit, PostState>(
                      builder: (context, state) {
                        // posts loaded state
                        if (state is PostLoaded) {
                          // filter the posts to only show the current user's posts
                          final userPosts = state.posts.where((post) => post.userId == widget.uid).toList();
                          postCount = userPosts.length; // update post count
                          
                          // Use GridView for an Instagram-like grid display (3 columns)
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                            ),
                            itemCount: userPosts.length,
                            itemBuilder: (context, index) {
                              final post = userPosts[index];
                              return CachedNetworkImage(
                                imageUrl: post.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              );
                            },
                          );
                        } else {
                          return const Center(child: Text("Loading posts..."));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
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
