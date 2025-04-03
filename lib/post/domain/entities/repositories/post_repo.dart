// Purpose: Outline the possible operations in regards to posts
// i.g. fetch all posts
import 'package:dmessages/post/domain/entities/post.dart';

abstract class PostRepo{
  Future<List<Post>> fetchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  // userid? or userId?
  Future<List<Post>> fetchPostsByUserID(String userId);
}
