// Track the different types of post state there wil be
import 'package:dmessages/post/domain/entities/post.dart';

abstract class PostState {}

// initial state
class PostInitial extends PostState {}

// loading....
class PostLoading extends PostState {}

// uploading...
class PostUpload extends PostState {}

// error states
class PostError extends PostState {
  final String message;
  PostError(this.message);
}

// loaded state
class PostLoaded extends PostState {
  final List<Post> posts;
  PostLoaded(this.posts);
}
