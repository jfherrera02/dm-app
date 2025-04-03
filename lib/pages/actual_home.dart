import 'package:dmessages/components/my_drawer.dart';
import 'package:dmessages/pages/calendar_page.dart';
import 'package:dmessages/pages/friends_page.dart';
import 'package:dmessages/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class ActualHome extends StatefulWidget {
  const ActualHome({super.key});

  @override
  State<ActualHome> createState() => _ActualHomeState();
}

class _ActualHomeState extends State<ActualHome> {
  int _selectedIndex = 0;

  // bottom nav bar
  final List<Widget> _pages = [
    const HomeFeed(), // Replaces placeholder text with HomeFeed
    FriendPage(),
    CalendarPage(),
    // requires uid to view profiles 
    // so before that we must get the 
    // current user's id -->
    //final user = context.read<AuthCubit>().currentUser; 
    //UserProfilePage('1'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Tether"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      drawer: MyDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
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

class HomeFeed extends StatelessWidget {
  const HomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stories Section
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/story_placeholder.png'),
                    ),
                    const SizedBox(height: 5),
                    Text('User $index', style: TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/user_placeholder.png'),
                      ),
                      title: Text('User $index'),
                      subtitle: Text('2 hours ago'),
                    ),
                    // Image.asset('assets/post_placeholder.png', fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.favorite_border),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.comment),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Liked by User A and 100 others', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text('User $index: This is a sample caption for the post!'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
