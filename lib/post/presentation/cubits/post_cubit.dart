import 'package:dmessages/post/presentation/cubits/post_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
/*
class PostCubit extends Cubit<PostState {
  final PostRepo postRepo;
  final StorageRepo;

  PostCubit({
    required this.postRepo, 
    required this.storageRepo,
    }) : super(PostInitial());

  // now we can create a new post 
  // accept a post and OPTIONALLY accept and image form the path/byte mobile/web
  // create
  Future<void> createPost(Post post,
  {string? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl; 

    try {
      // now take care of image upload via mobile platform (File path)
    if (imagePath != null) {
      emit(PostUpload());

      // reuse the method for uploading profile images
      imageUrl = await StorageRepo.uploadProfileImageMobile(ImagePath, post.id);
    }

      // now handle the case for web platforms (this time with file bytes)
      else if (imageBytes != null) {
        emit(PostUpload());
        imageUrl = await StorageRepo.uploadProfileImageMobile(imageBytes, post.id);
      }

      // give the image url to the post 
      final newPost = post.copyWith(imageUrl: imageUrl);


      // now we can create the post in the backend 
      postRepo.createPost(newPost); 
    } catch (e) {
      emit(PostError("Fao;ed creating a post: $e"));
   }
  }

  // then we can fetch all posts 
  Future<void> fetchAllPosts() async {
    try{
      emit(PostLoading());
    final posts = await postRepo.fetchAllPosts();
    emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError("Fao;ed creating a post: $e"));
    }
  }

  // delete a post 


  // 
}

*/