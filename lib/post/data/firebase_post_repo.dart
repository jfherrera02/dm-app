// implements the PostRepo from /doman/entities/post_repo
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dmessages/post/domain/entities/post.dart';
import 'package:dmessages/post/domain/entities/post_comments.dart';
import 'package:dmessages/post/domain/entities/repositories/post_repo.dart';

class FirebasePostRepo implements PostRepo{
  // grab firestore
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // store the posts in a collection named 'posts'
  final CollectionReference postsCollection = 
    FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(Post post) async{
    try{
      // convert whicherver post to the json format and save it 
      await postsCollection.doc(post.id).set(post.toJson());
    }catch (e){
      throw Exception("Error creating post: $e");
    }

  }
  @override

  Future<void> deletePost(String postId) async {
    // go through the collection and delete the post
    await postsCollection.doc(postId).delete();   
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
    // get all posts with the most recent posts at the top
    final postsSnapshot = await postsCollection.orderBy('timestamp', descending: true).get();

    // then convert the firestore document from json --> list of posts
    final List<Post> allPosts = postsSnapshot.docs
    .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
    .toList();
    // end 

    return allPosts;
    
    } catch (e) {
      throw Exception("Error when fetching posts: $e");
    }
  }
  @override
  Future<List<Post>> fetchPostsByUserID(String userId) async {
    // fetch by userId
    // useful for friend fetch/ search/ profile view
    
    // here we fetch with this id
    try {
      final postsSnapshot = 
        await postsCollection.where('userId', isEqualTo: userId).get();
      
      // then conver the firestore docs from json --> list of posts
      final userPosts = postsSnapshot.docs
      .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>)).toList();

      return userPosts;  
    } catch (e) {
      throw Exception("Error when attempting to fetch posts by user: $e"); 
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    
    // toggle the like on the post
    try {
      // get the post document
      final postDoc = postsCollection.doc(postId);
      // get the current likes on the post
      final postSnapshot = await postDoc.get();
      final postData = postSnapshot.data() as Map<String, dynamic>;
      // get the likes list from the post data
      // if the likes list is null then we create an empty list
      final List<String> likes = List<String>.from(postData['likes'] ?? []);

      // check if the user has already liked the post
      if (likes.contains(userId)) {
        // remove the user from the likes list
        likes.remove(userId);
      } else {
        // add the user to the likes list
        likes.add(userId);
      }

      // update the post document with the new likes list
      await postDoc.update({'likes': likes});
    } catch (e) {
      throw Exception("Error toggling like on post: $e");
    }
  }

  @override
  Future<void> addCommentToPost(String postId, PostComments comment) async {
    // add a comment to the post
    try {
      // get the post document
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists){
        // convert json to a post object
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // then add the new comment to the post
        post.comments.add(comment);

        // update the post document in firestore
        await postDoc.reference.update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error adding comment to post: $e");
    }
  }

  @override
  Future<void> deleteCommentFromPost(String postId, String commentId) async {
    // delete a comment from the post
    try {
      // get the post document
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists){
        // convert json to a post object
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // then remove the comment from the post
        post.comments.removeWhere((comment) => comment.id == commentId);

        // update the post document in firestore
        await postDoc.reference.update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error removing comment from post: $e");
    }
  }
}