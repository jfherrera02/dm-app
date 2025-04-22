import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_cubit.dart';
import 'package:dmessages/pages/profile/data/profile_user.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_page.dart';
import 'package:dmessages/post/domain/entities/post.dart';
import 'package:dmessages/post/domain/entities/post_comments.dart';
import 'package:dmessages/post/presentation/cubits/post_cubit.dart';
import 'package:dmessages/services/auth/domain/app_user.dart';
import 'package:dmessages/services/auth/presentation/cubits/auth_cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  // constructor to pass the post object to the widget
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });
  // this is the state of the post tile
  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  // cubits to be used in this widget
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;
  // current user
  // this is the user that is currently logged in
  AppUser? currentUser;

  // post user
  // this is the user that is currently being viewed
  ProfileUser? postUser;

  // logged in profile user (for new comment avatar)
  ProfileUser? me;

  // comment text controller
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // get the current user
    getCurrentUser();
    // fetch post author profile
    fetchPostUser();
    // fetch my profile for comment avatar
    fetchMyProfile();
  }

  // get the current user from auth cubit
  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.newgetCurrentUser;
    isOwnPost = currentUser?.uid == widget.post.userId;
  }

  // fetch the post author's profile
  Future<void> fetchPostUser() async {
    final fetchedUser =
        await profileCubit.getCurrentUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    } else {
      developer.log("Post user not found");
    }
  }

  // fetch my own profile for comment input avatar
  Future<void> fetchMyProfile() async {
    if (currentUser == null) return;
    final fetched = await profileCubit.getCurrentUserProfile(currentUser!.uid);
    if (fetched != null) {
      setState(() {
        me = fetched;
      });
    }
  }

  // load commenter profiles by UID
  Future<Map<String, ProfileUser>> loadCommenters() async {
    final ids = widget.post.comments.map((c) => c.uid).toSet().toList();
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('uid', whereIn: ids)
        .get();
    return {
      for (var doc in snapshot.docs)
        doc.data()['uid'] as String: ProfileUser.fromJson(doc.data()),
    };
  }

  // like button pressed
  void onLikePressed() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });
    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  // open modal sheet for comments
  void openCommentsModalSheet() async {
    // Preload commenters to avoid in-sheet futures
    Map<String, ProfileUser> userMap = {};
    if (widget.post.comments.isNotEmpty) {
      try {
        userMap = await loadCommenters();
      } catch (e) {
        developer.log("Error loading commenters: \$e");
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // drag indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Comments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                // comments list or placeholder
                Expanded(
                  child: widget.post.comments.isEmpty
                      ? const Center(child: Text('No comments yet'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: widget.post.comments.length,
                          itemBuilder: (context, index) {
                            final comment = widget.post.comments[index];
                            final commenter = userMap[comment.uid];
                            return ListTile(
                              leading: (commenter?.profileImageUrl ?? '')
                                      .isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: commenter!.profileImageUrl,
                                      imageBuilder: (ctx, img) => CircleAvatar(
                                        radius: 15,
                                        backgroundImage: img,
                                      ),
                                      placeholder: (_, __) =>
                                          const CircularProgressIndicator(
                                              strokeWidth: 2),
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.error),
                                    )
                                  : const Icon(Icons.person),
                              title: Text(
                                comment.username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              subtitle: Text(comment.text),
                              trailing: Text(
                                timeago.format(comment.timestamp),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                ),
                // new comment input
                Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Row(
                    children: [
                      if (me != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(me!.profileImageUrl),
                          ),
                        ),
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.1),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          addCommentToPost();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // add a comment with optimistic UI update
  void addCommentToPost() {
    final commentText = commentController.text.trim();
    if (commentText.isNotEmpty) {
      final newComment = PostComments(
        postId: widget.post.id,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        uid: currentUser!.uid,
        username: currentUser!.username,
        text: commentText,
        timestamp: DateTime.now(),
      );
      setState(() {
        widget.post.comments.add(newComment);
      });
      postCubit
          .addCommentToPost(widget.post.id, newComment)
          .catchError((error) {
        setState(() {
          widget.post.comments.remove(newComment);
        });
        developer.log("Error adding comment: \$error");
      });
      commentController.clear();
    }
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                widget.onDeletePressed!();
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(uid: widget.post.userId),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : const Icon(Icons.person),
                  const SizedBox(width: 10),
                  Text(
                    widget.post.userName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (isOwnPost)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: showOptions,
                      color: Colors.red,
                    ),
                ],
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 400,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.post.text,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onLikePressed,
                    child: Icon(
                      widget.post.likes.contains(currentUser!.uid)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.post.likes.contains(currentUser!.uid)
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.text,
                  child: Text(
                    "${widget.post.likes.length}",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.comment),
                  onPressed: openCommentsModalSheet,
                  color: Colors.grey,
                ),
                Text(
                  widget.post.comments.length.toString(),
                  style: const TextStyle(fontSize: 14),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                  color: Colors.grey,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    widget.post.timestamp != null
                        ? timeago.format(widget.post.timestamp)
                        : "Just now",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
