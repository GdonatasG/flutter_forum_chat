import 'package:flutterforum/model/post.dart';

abstract class AddPostPageEvent {
  const AddPostPageEvent();
}

class ReloadCurrentUser extends AddPostPageEvent {
  ReloadCurrentUser();

  List<Object> get props => [];
}

class AddPostIntoFirestore extends AddPostPageEvent {
  final Post post;
  AddPostIntoFirestore(this.post);

  List<Object> get props => [post];
}
