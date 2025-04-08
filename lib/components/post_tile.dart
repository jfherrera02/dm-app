import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_cubit.dart';
import 'package:dmessages/pages/profile/profile_user.dart';
import 'package:dmessages/post/domain/entities/post.dart';
import 'package:dmessages/post/presentation/cubits/post_cubit.dart';
import 'package:dmessages/services/auth/domain/app_user.dart';
import 'package:dmessages/services/auth/presentation/cubits/auth_cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostTile extends StatefulWidget{
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
      setState(()
      {
        postUser = fetchedUser;
      });
    }
    // if the post user is null then we can show an error message
    if (fetchedUser == null) {
      log("Post user not found");
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
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          Row(
            // In the top section include:
            // 1. Profile image of the user who posted the post
            // 2. Name of the user who posted the post
            // 3. Delete button (if the post is owned by the current user)
            
            // name of the user who posted the post
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // profile image of the user who posted the post
              postUser?.profileImageUrl != null ?
              // if the post user is not null then show the profile image
              CachedNetworkImage(
                imageUrl: postUser!.profileImageUrl,
                errorWidget: (context, url, error) => const Icon(Icons.error),
                imageBuilder: (context, imageProvider) => Container(
                  width: 50,
                  height: 50,
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
              Text(
                widget.post.userName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // only show if its the user's post
              // delete button
              if (isOwnPost) 
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: widget.onDeletePressed == null ? null : showOptions,
                color: Colors.red,
              ),            
            ],
          ),
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
            const Icon(Icons.error),
          ),
        ],
      ),
    );
  }
}

