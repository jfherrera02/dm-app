import 'dart:typed_data';

import 'package:dmessages/features/domain/storage_repository.dart';
import 'package:dmessages/post/domain/entities/post.dart';
import 'package:dmessages/post/domain/entities/post_comments.dart';
import 'package:dmessages/post/domain/entities/repositories/post_repo.dart';
import 'package:dmessages/post/presentation/cubits/post_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepository storageRepo;
  // constructor
  // accept the post repo and the storage repo

  // this is the repo that will be used to upload images to the backend
  PostCubit({
    required this.postRepo,
    required this.storageRepo,
  }) : super(PostInitial());

  // now we can create a new post
  // accept a post and OPTIONALLY accept and image form the path/byte mobile/web
  // create
  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;

    try {
      // now take care of image upload via mobile platform (File path)
      if (imagePath != null) {
        emit(PostUpload());

        // reuse the method for uploading profile images
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }

      // now handle the case for web platforms (this time with file bytes)
      else if (imageBytes != null) {
        emit(PostUpload());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      // give the image url to the post
      final newPost = post.copyWith(imageUrl: imageUrl);

      // now we can create the post in the backend
      postRepo.createPost(newPost);

      // and refetch all posts
      fetchAllPosts();
    } catch (e) {
      emit(PostError("Failed creating a post: $e"));
    }
  }

  // then we can fetch all posts
  Future<void> fetchAllPosts() async {
    try {
      emit(PostLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError("Failed fetch posts: $e"));
    }
  }

  // delete a post
  Future<void> deletePost(String postId) async {
    try {
      emit(PostLoading());
      await postRepo.deletePost(postId);
      // emit(PostDeleted("Post deleted successfully"));
    } catch (e) {
      emit(PostError("Failed deleting a post: $e"));
    }
  }

  // toggle like a post
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostError("Failed toggling like: $e"));
    }
  }

  // add a comment to a post
  Future<void> addCommentToPost(String postId, PostComments comment) async {
    try {
      await postRepo.addCommentToPost(postId, comment);
    } catch (e) {
      emit(PostError("Failed adding comment: $e"));
    }
  }

  // delete a comment from a post
  Future<void> deleteCommentFromPost(String postId, String commentId) async {
    try {
      await postRepo.deleteCommentFromPost(postId, commentId);
    } catch (e) {
      emit(PostError("Failed deleting comment: $e"));
    }
  }
}
