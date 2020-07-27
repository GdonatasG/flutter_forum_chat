import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterforum/model/comment.dart';

class CommentService {
  final CollectionReference commentsCollection =
      Firestore.instance.collection('comments');

  Query getCommentsOfPost(String postId) => commentsCollection
      .where('postId', isEqualTo: postId)
      .orderBy('createdAt', descending: false);

  Future<DocumentReference> addNewComment(Comment comment) {
    return commentsCollection.add(comment.toMap());
  }

  Future<void> deleteCommentById(String id) =>
      commentsCollection.document(id).delete();
}
