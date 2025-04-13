import 'package:dmessages/components/my_drawer.dart';
import 'package:dmessages/post/post_components/post_tile.dart';
import 'package:dmessages/pages/calendar_page.dart';
import 'package:dmessages/pages/friends_page.dart';
import 'package:dmessages/pages/profile_page.dart';
import 'package:dmessages/post/presentation/cubits/post_cubit.dart';
import 'package:dmessages/post/presentation/cubits/post_states.dart';
import 'package:dmessages/post/presentation/pages/upload_post_page.dart';
import 'package:dmessages/services/auth/presentation/cubits/auth_cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class ActualHome extends StatefulWidget {
  const ActualHome({super.key});

  @override
  State<ActualHome> createState() => _ActualHomeState();
}

class _ActualHomeState extends State<ActualHome> {
  // grab the post cubit from the context
  late final postCubit = context.read<PostCubit>();

  // on startup we can fetch the posts
  @override
  void initState() {
    super.initState();
    // fetch the posts from the backend
    fetchAllPosts();
  }

  // fetch all posts from the backend
  void fetchAllPosts() async {
    // fetch all posts from the backend
    await postCubit.fetchAllPosts();
  }

  // method to delete a post
  void deletePost(String postId) async {
    // delete the post from the backend
    await postCubit.deletePost(postId);
    // fetch all posts from the backend
    await postCubit.fetchAllPosts();
    // show a snackbar to inform the user that the post has been deleted
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Post deleted successfully"),
      ),
    );
  }

  // this is the index of the selected tab
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().newgetCurrentUser;
    String? uid = user!.uid;

    // bottom nav bar
    final List<Widget> pages = [
      const HomeFeed(), // Replaces placeholder text with HomeFeed
      FriendPage(),
      CalendarPage(),
      // requires uid to view profiles 
      // so before that we must get the 
      // current user's id -->
      UserProfilePage(uid: uid),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Tether"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification button press
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings button press
            },
          ),
          // upload new post button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadPostPage(),
              ),
            ),
            // Handle upload new post button press
          ),
        ],
      ),
      drawer: MyDrawer(),

      // New logic: only show BlocBuilder when Home tab is selected
      body: _selectedIndex == 0
          ? BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                // the possible states are:
                // 1. loading
                if (state is PostLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // 2. loaded
                else if (state is PostLoaded) {
                  final allPosts = state.posts;

                  // but if its empty we can show a message
                  if (allPosts.isEmpty) {
                    return const Center(
                      child: Text("No posts available"),
                    );
                  }

                  // otherwise we can show the posts
                  // return a list view of the posts
                  return ListView.builder(
                    itemCount: allPosts.length,
                    itemBuilder: (context, index) {
                      final post = allPosts[index];
                      return PostTile(
                        post: post,
                        onDeletePressed: () => deletePost(post.id),
                      );
                    },
                  ); 
                }
                // 3. uploading
                else if (state is PostUpload) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // 4. error
                else if (state is PostError) {
                  return const Center(
                    child: Text("Error loading posts"),
                  );
                } else {
                  return const SizedBox();
                }
              },
            )
          // ⬇When another tab is selected, render the appropriate page
          : pages[_selectedIndex],

      bottomNavigationBar: GNav(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        gap: 8,
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        tabs: const [
          GButton(icon: Icons.home, text: 'Home'),
          GButton(icon: Icons.people, text: 'Friends'),
          GButton(icon: Icons.event, text: 'Calendar'),
          GButton(icon: Icons.account_circle, text: 'Profile'),
        ],
      ),
    );
  }
}

// This is a placeholder for the actual home feed page.
class HomeFeed extends StatelessWidget {
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Home Feed"),
    );
  }
}
