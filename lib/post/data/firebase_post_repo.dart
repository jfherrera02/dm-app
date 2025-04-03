// implements the PostRepo from /doman/entities/post_repo
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dmessages/post/domain/entities/post.dart';
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
}