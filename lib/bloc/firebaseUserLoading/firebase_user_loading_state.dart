import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseUserLoadingState {
  const FirebaseUserLoadingState();
}

class FirebaseUserLoadingInitial extends FirebaseUserLoadingState {
  const FirebaseUserLoadingInitial();

  List<Object> get props => [];
}

class FirebaseUserLoading extends FirebaseUserLoadingState {
  const FirebaseUserLoading();

  List<Object> get props => [];
}

class FirebaseUserLoaded extends FirebaseUserLoadingState {
  final FirebaseUser user;

  FirebaseUserLoaded(this.user);

  List<Object> get props => [user];
}

class FirebaseUserLoadingError extends FirebaseUserLoadingState {
  final String error;

  FirebaseUserLoadingError(this.error);

  List<Object> get props => [error];
}

class FirebaseUserLoadingSignOutSuccessful extends FirebaseUserLoadingState {
  FirebaseUserLoadingSignOutSuccessful();

  List<Object> get props => [];
}

class FirebaseUserLoadingSignOutError extends FirebaseUserLoadingState {
  final String error;

  FirebaseUserLoadingSignOutError(this.error);

  List<Object> get props => [error];
}
