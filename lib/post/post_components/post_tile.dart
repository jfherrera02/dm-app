import 'dart:developer' as developer;
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

  // startup method
  @override
  void initState() {
    super.initState();
    // get the current user
    getCurrentUser();
    fetchPostUser();
  }

  // like button pressed
  void onLikePressed() {
    // grab current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // optmistically update the UI
    // before the API call is made
    // this will be a heart icon that will change color when pressed
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid); // unlike the post
      } else {
        widget.post.likes.add(currentUser!.uid); // like the post
      }
    });
    
    // but now we need to error handle the case when the API call fails
    // then update the like status
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((error) {
      // if the error occurs then we need to revert the UI back to the original state
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    // get the current user from the auth cubit
    currentUser = authCubit.newgetCurrentUser;
    // once we get the current user we can fetch the post user
    // to know whether to show the delete button or not
    isOwnPost = currentUser!.uid == widget.post.userId;
  }

  Future<void> fetchPostUser() async {
    // fetch the post user from the backend
    final fetchedUser = await profileCubit.getCurrentUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
    // if the post user is null then we can show an error message
    if (fetchedUser == null) {
      developer.log("Post user not found");
      return;
    }
  }
    // show options to delete the post
  void showOptions() {
    // show a dialog to confirm the deletion of the post
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Post"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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

  // this will be the function to go to the comments page
  // comment text controller
  final TextEditingController commentController = TextEditingController();

  // then we can open a comment box so the user can add a comment/type
  void openCommentBox() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add a comment"),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(
              hintText: "Type your comment here",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),

            // add a save button to save the comment
            TextButton(
              onPressed: () {
                addCommentToPost();
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }
  
  // NEW: Implement a modal bottom sheet for viewing comments
  void openCommentsModalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allows the sheet to adjust with the keyboard
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // small indicator for dragging the sheet
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                // Expanded list view for comments
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: widget.post.comments.length,
                    itemBuilder: (context, index) {
                      final comment = widget.post.comments[index];
                      return ListTile(
                        // UPDATED: Instead of using comment.profileImageUrl, use postUser.profileImageUrl
                        // showing a placeholder icon for commenter's profile image handled via PostUser
                        leading: postUser?.profileImageUrl != null
                            ? CachedNetworkImage(
                                // use the profile image URL of the commenter
                                // match username with database usernames to access their corresponding profile image
                                imageUrl: postUser!.profileImageUrl,
                                width: 30,
                                height: 30,
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
                                placeholder: (context, url) => const CircularProgressIndicator(strokeWidth: 2),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              )
                            : const Icon(Icons.person),
                        title: Text(comment.username),
                        subtitle: Text(comment.text),
                      );
                    },
                  ),
                ),
                // input field for new comment in the modal bottom sheet
                Padding(
                  padding: MediaQuery.of(context).viewInsets, // adjust for keyboard
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: "Add a comment...",
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            // lower opacity for the text field background
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          addCommentToPost();
                          // Optionally keep the sheet open for more comments or close it:
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

  // add a comment to the post with optimistic UI update
  void addCommentToPost() {
    // get the comment text from the text field
    final commentText = commentController.text.trim();
    // check if the comment text is not empty
    if (commentText.isNotEmpty) {
      // create a new comment object
      final newComment = PostComments(
        postId: widget.post.id,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: currentUser!.username, // or use currentUser!.username if preferred
        text: commentText,
        timestamp: DateTime.now(),
      );
      // optimistic update: immediately add the new comment to the post's comment list
      setState(() {
        widget.post.comments.add(newComment);
      });
      // add the comment to the post in the backend
      postCubit.addCommentToPost(widget.post.id, newComment).catchError((error) {
        // if the backend call fails, revert the optimistic update
        setState(() {
          widget.post.comments.remove(newComment);
        });
        // log the error (you may also show a snackbar or dialog)
        developer.log("Error adding comment: $error");
      });
      // clear the text field
      commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          // wrap in gesture detector to show the post user profile page
          GestureDetector(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => UserProfilePage(uid: widget.post.userId,)
              )
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                // In the top section include:
                // 1. Profile image of the user who posted the post
                // 2. Name of the user who posted the post
                // 3. Delete button (if the post is owned by the current user)
                
                // name of the user who posted the post
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // profile image of the user who posted the post
                  postUser?.profileImageUrl != null ?
                  // if the post user is not null then show the profile image
                  CachedNetworkImage(
                    imageUrl: postUser!.profileImageUrl,
                    errorWidget: (context, url, error) => const Icon(Icons.error),
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
                  ) : const Icon(Icons.person),
                  // name of the user who posted the post
                  const SizedBox(width: 10),
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      // align to the left
                    ),
                  ),
                  // only show if its the user's post
                  // delete button
                  // align to the right
                  const Spacer(),
                  if (isOwnPost) 
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: widget.onDeletePressed == null ? null : showOptions,
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
            errorWidget: (context, url, error) =>
              const Icon(Icons.error),
          ),

          // post description
          // align to the left
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

          // like button 
          // this will be a heart icon that will change color when pressed
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
                
                // number of likes
                // this will be a text that will show the number of likes
                MouseRegion(
                  cursor: SystemMouseCursors.text,
                  child: Text(
                    "${widget.post.likes.length}",
                    style: const TextStyle(
                      fontSize: 14,
                      // color: Colors.grey,
                    ),
                  ),
                ),
              
                // comment button
                // this will be a button that will take the user to the comments page
                IconButton(
                  icon: const Icon(Icons.comment),
                  // Updated to open modal bottom sheet for comments instead of alert dialog
                  onPressed: openCommentsModalSheet,
                  color: Colors.grey,
                ),
            
                // show comment count
                Text(
                  widget.post.comments.length.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    // color: Colors.grey,
                  ),
                ),   
            
                // share button
                // this will be a button that will take the user to the share page
                // will be a placeholder for now
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {},
                  color: Colors.grey,
                ),
                
                // spacing
                const SizedBox(height: 10),
                
                // timestamp of the post
                // and display the time passed since the post was created
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    // use timeago package to show the time passed since the post was created
                    // if the timestamp is null then show "Just now"
                    widget.post.timestamp != null 
                      ? timeago.format(widget.post.timestamp)
                      : "Just now",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // show the comments section
          // start with a caption of the comments
        ],
      ),
    );
  }
}
