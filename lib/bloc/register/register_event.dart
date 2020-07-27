import 'package:flutterforum/model/user.dart';

abstract class RegisterEvent {
  const RegisterEvent();
}

class RegisterUser extends RegisterEvent {
  final User user;
  final String email;
  final String password;

  RegisterUser(this.user, this.email, this.password);

  List<Object> get props => [user, email, password];
}
