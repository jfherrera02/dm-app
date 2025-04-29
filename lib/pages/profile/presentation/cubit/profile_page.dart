
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dmessages/components/bio.dart';
import 'package:dmessages/pages/profile/presentation/cubit/edit_profile.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_cubit.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_states.dart';
import 'package:dmessages/post/presentation/cubits/post_cubit.dart';
import 'package:dmessages/post/presentation/cubits/post_states.dart';
import 'package:dmessages/responsive/constrained_scaffold.dart';
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
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.profileUser;
          String userCountry = user.country;
          // Parse the country string to get the flag and country name ONLY
          String userCountryParse = userCountry.split('[').first.trim();
          // Evict cache for the profile image to ensure a fresh download.
          Future.delayed(Duration.zero, () {
            CachedNetworkImage.evictFromCache(user.profileImageUrl);
          });

          return ConstrainedScaffold(
            // no AppBar, custom header below
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // custom header with country flag and settings icon
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          // back button
                          // only show back button if not own profile
                          if (user.uid != currentUser?.uid)
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () => Navigator.pop(context),
                            ),
                          // user's country flag or default icon
                          userCountryParse.isNotEmpty
                              ? Text(userCountryParse, style: const TextStyle(fontSize: 18))
                              : const Icon(Icons.flag, size: 24),
                          const Spacer(),
                          // settings icon only on own profile
                          if (user.uid == currentUser?.uid)
                            IconButton(
                              icon: const Icon(Icons.settings),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfile(user: user),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // banner
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context).colorScheme.surface,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // profile image and stats
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Row(
                      children: [
                        // profile image
                        CachedNetworkImage(
                          key: ValueKey(user.profileImageUrl),
                          imageUrl: user.profileImageUrl,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 90,
                            color: Theme.of(context).colorScheme.primary,
                          ),
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
                        const SizedBox(width: 24),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // posts count
                              BlocBuilder<PostCubit, PostState>(
                                builder: (context, postState) {
                                  final count = postState is PostLoaded
                                      ? postState.posts
                                          .where((p) => p.userId == widget.uid)
                                          .length
                                      : 0;
                                  return Column(
                                    children: [
                                      Text(
                                        '$count',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Posts',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.color
                                                    ?.withAlpha(150)),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              // followers count
                              Column(
                                children: [
                                  Text(
                                    '$friendCount',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Followers',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withAlpha(150)),
                                  ),
                                ],
                              ),
                              // following count
                              Column(
                                children: [
                                  Text(
                                    '$friendCount',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Following',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.color
                                                ?.withAlpha(150)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // username and bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.username,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.inversePrimary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Bio(text: user.bio),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  // posts grid
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: BlocBuilder<PostCubit, PostState>(
                      builder: (context, state) {
                        if (state is PostLoaded) {
                          final userPosts = state.posts
                              .where((p) => p.userId == widget.uid)
                              .toList();
                          if (userPosts.isEmpty) {
                            return const Center(child: Text('No posts yet'));
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                              childAspectRatio: 1,
                            ),
                            itemCount: userPosts.length,
                            itemBuilder: (context, idx) {
                              final post = userPosts[idx];
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 0.5),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: post.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const Center(child: Text("No Profile was found."));
        }
      },
    );
  }
}
