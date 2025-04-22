// Purpose: Outline the possible operations in regards to posts
// i.g. fetch all posts
import 'package:dmessages/post/domain/entities/post.dart';
import 'package:dmessages/post/domain/entities/post_comments.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  // userid? or userId?
  //  can be used to fetch posts by a specific user
  //  or to fetch posts by a specific userId
  Future<List<Post>> fetchPostsByUserID(String userId);

  Future<void> toggleLikePost(String postId,
      String userId); // this will be used to like or unlike a post
  Future<void> addCommentToPost(String postId,
      PostComments comment); // this will be used to add a comment to a post
  Future<void> deleteCommentFromPost(String postId,
      String commentId); // this will be used to delete a comment from a post
}
