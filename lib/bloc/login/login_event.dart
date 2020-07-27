abstract class LoginEvent {
  const LoginEvent();
}

class LoginWithEmailAndPassword extends LoginEvent {
  final String email;
  final String password;

  LoginWithEmailAndPassword(this.email, this.password);

  List<Object> get props => [email, password];
}

class LoginWithGoogleAccount extends LoginEvent {
  LoginWithGoogleAccount();

  List<Object> get props => [];
}
