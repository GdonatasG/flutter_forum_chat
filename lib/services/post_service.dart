import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterforum/model/post.dart';

class PostService {
  final CollectionReference postCollection =
      Firestore.instance.collection('posts');

  Query getCategoryPosts(String categoryId) =>
      postCollection.where('categoryId', isEqualTo: categoryId);

  DocumentReference getpostById(String postId) =>
      postCollection.document(postId);

  Future<DocumentReference> addNewPost(Post post) async {
    return await postCollection.add(post.toMap());
  }

  Future<void> updateLikedList(
      String postId, List<dynamic> listOfLikedBy) async {
    return await postCollection
        .document(postId)
        .updateData({'listOfLikedBy': listOfLikedBy});
  }
}
