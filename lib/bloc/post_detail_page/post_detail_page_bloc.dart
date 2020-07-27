import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterforum/services/comment_service.dart';
import 'package:flutterforum/services/post_service.dart';
import 'package:flutterforum/services/user_service.dart';

class PostDetailPageBloc {
  final PostService _postService;
  final UserService _userService;
  final CommentService _commentService;

  PostDetailPageBloc(
      this._postService, this._userService, this._commentService);

  Stream<DocumentSnapshot> getPostById(String postId) =>
      _postService.getpostById(postId).snapshots();

  Stream<QuerySnapshot> getCommentsOfPost(String postId) =>
      _commentService.getCommentsOfPost(postId).snapshots();

  Stream<DocumentSnapshot> streamFirestoreUser(String uid) =>
      _userService.getFirestoreUserById(uid).snapshots();

  Future<void> updateLikedList(
          String postId, List<dynamic> listOfLikedBy) async =>
      await _postService.updateLikedList(postId, listOfLikedBy);
}
