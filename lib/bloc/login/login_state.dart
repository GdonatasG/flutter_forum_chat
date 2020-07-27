import 'package:firebase_auth/firebase_auth.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();

  List<Object> get props => [];
}

class LoginWithEmailAndPasswordSuccessful extends LoginState {
  final FirebaseUser user;

  LoginWithEmailAndPasswordSuccessful(this.user);

  List<Object> get props => [user];
}

class LoginWithGoogleSuccessful extends LoginState {
  final FirebaseUser user;
  LoginWithGoogleSuccessful(this.user);

  List<Object> get props => [user];
}

class LoginError extends LoginState {
  final String error;

  LoginError(this.error);

  List<Object> get props => [error];
}
