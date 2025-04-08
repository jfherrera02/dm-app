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
                    style: TextStyle(color: Theme.of(context).colorScheme.primary
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
                    imageUrl: user.profileImageUrl,
                    // when loading.... ->
                    placeholder: (context, url) => 
                  const CircularProgressIndicator(),
                  // in case of an error ->
                  errorWidget: (context, url, error) => 
                  Icon(Icons.person,
                  size: 68,
                  color: Theme.of(context).colorScheme.primary,
                 ),
                // when loaded:
                imageBuilder: (context, imageProvider) => Image(
                  image: imageProvider,
                  // now ensure the image fills up the profile image area
                 fit: BoxFit.cover,
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
              body: Center(child: CircularProgressIndicator(),
              ),
            );
          } else {
            return const Center(child: Text("No Profile was found."),
            );
          }
        },
      );
  }
}
/*
  // Fetch User Profile Data
  Future<void> _fetchUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      DocumentSnapshot userDoc = await _firestore.collection('Users').doc(user.uid).get();
      if (!userDoc.exists) return;

      setState(() {
        _userName = userDoc.get('username');
        _profileImageUrl = userDoc.get('profileImageUrl') ?? '';
        _bio = userDoc.get('bio') ?? 'No bio yet.';
        _followers = (userDoc.get('followers') as List<dynamic>?)?.length ?? 0;
        _following = (userDoc.get('following') as List<dynamic>?)?.length ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }
  */ 
/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_userName ?? "Profile", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildProfileStats(),
                  const SizedBox(height: 15),
                  _buildEditProfileButton(),
                  const SizedBox(height: 10),
                  _buildPostGrid(),
                ],
              ),
            ),
    );
  }

  // Profile Header (Profile Picture & Username)
  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
              ? NetworkImage(_profileImageUrl!)
              : null,
          child: _profileImageUrl == null || _profileImageUrl!.isEmpty
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 10),
        Text(
          _userName ?? "User",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          _bio ?? "No bio yet.",
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // Follower & Following Stats
  Widget _buildProfileStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatColumn("Followers", _followers),
        const SizedBox(width: 30),
        _buildStatColumn("Following", _following),
      ],
    );
  }

  // Stats Column Widget
  Widget _buildStatColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  // Edit Profile Button
  Widget _buildEditProfileButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement edit profile functionality
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Edit Profile"),
      ),
    );
  }

  // Post Grid Placeholder
  Widget _buildPostGrid() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9, // Placeholder for posts
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[300],
          );
        },
      ),
    );
  }
}
*/