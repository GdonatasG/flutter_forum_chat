import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterforum/services/comment_service.dart';
import 'package:flutterforum/services/post_service.dart';
import 'package:flutterforum/services/user_service.dart';

class PostsPageBloc {
  final PostService _postService;
  final UserService _userService;
  final CommentService _commentService;

  PostsPageBloc(this._postService, this._userService, this._commentService);

  Stream<QuerySnapshot> getCategoryPosts(String categoryId) =>
      _postService.getCategoryPosts(categoryId).snapshots();

  Stream<QuerySnapshot> getCommentsOfPost(String postId) =>
      _commentService.getCommentsOfPost(postId).snapshots();

  Stream<DocumentSnapshot> streamFirestoreUser(String uid) =>
      _userService.getFirestoreUserById(uid).snapshots();
}
