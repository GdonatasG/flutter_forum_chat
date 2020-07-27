import 'package:firebase_auth/firebase_auth.dart';

abstract class AddPostPageState {
  const AddPostPageState();
}

class AddPostPageInitial extends AddPostPageState {
  const AddPostPageInitial();

  List<Object> get props => [];
}

class AddPostPageFirebaseUserLoaded extends AddPostPageState {
  final FirebaseUser user;

  AddPostPageFirebaseUserLoaded(this.user);

  List<Object> get props => [this.user];
}

class AddPostPageFirebaseUserLoadingError extends AddPostPageState {
  final String error;

  AddPostPageFirebaseUserLoadingError(this.error);

  List<Object> get props => [this.error];
}

class AddPostPagePostAdded extends AddPostPageState {
  final String postId;

  const AddPostPagePostAdded(this.postId);

  List<Object> get props => [this.postId];
}

class AddPostPagePostingError extends AddPostPageState {
  final String error;

  AddPostPagePostingError(this.error);

  List<Object> get props => [this.error];
}

class AddPostPageNoInternet extends AddPostPageState {
  final String error;

  AddPostPageNoInternet(this.error);

  List<Object> get props => [this.error];
}
