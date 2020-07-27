import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterforum/model/user.dart';

abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();

  List<Object> get props => [];
}

class RegisterSuccessful extends RegisterState {
  final FirebaseUser fUser;
  final User user;

  RegisterSuccessful(this.fUser, this.user);

  List<Object> get props => [user];
}

class RegisterError extends RegisterState {
  final String error;

  RegisterError(this.error);

  List<Object> get props => [error];
}
