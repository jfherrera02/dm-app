import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings page
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile header (Profile pic, stats, edit button)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                ),
                const SizedBox(width: 20),

                // Followers / Following / Posts
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn("Posts", "0"),  // Placeholder for posts
                      _buildStatColumn("Friends", "120"),
                      _buildStatColumn("Following", "98"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Username & Bio
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Username",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 4),
                Text(
                  "This is your bio. Edit it to personalize your profile!",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Edit Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to edit profile page
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.grey.shade300,
                ),
                child: const Text("Edit Profile"),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Divider
          const Divider(),

          // Posts Grid (Placeholder)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: 9, // Placeholder for 9 images
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 images per row
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.grey.shade400, // Placeholder for images
                  child: const Icon(Icons.image, color: Colors.white, size: 40),
                );
              },
            ),
          ),
        ],
      ),

      // Floating Button for Adding Posts (Future Feature)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add post functionality
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Helper function for stats (Posts, Followers, Following)
  Widget _buildStatColumn(String label, String count) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
