import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterforum/model/user.dart';
import 'package:flutterforum/services/auth_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:rxdart/rxdart.dart';
import 'login_bloc_export.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthService _authService;
  final UserService _userService;

  LoginState get initialState => LoginInitial();

  // Controlling progress indicator
  // false - indicator is hidden
  // true - indicator is visible
  final _progressIndicatorController = BehaviorSubject<bool>.seeded(false);

  LoginBloc(this._authService, this._userService) : super(null);

  Stream<bool> get progressIndicatorStream =>
      _progressIndicatorController.stream;

  _updateIndicator({bool shouldShow}) {
    _progressIndicatorController.value = shouldShow;
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginWithEmailAndPassword) {
      _updateIndicator(shouldShow: true);
      try {
        AuthResult result = await _authService.signInWithEmailAndPassword(
            event.email, event.password);

        // checking email verification
        if (result.user.isEmailVerified)
          yield LoginWithEmailAndPasswordSuccessful(result.user);
        else
          yield LoginError("Email " + result.user.email + " is not verified");
      } catch (error) {
        print(error.toString());
        yield LoginError("Something went wrong, try again");
      }
      _updateIndicator(shouldShow: false);
    } else if (event is LoginWithGoogleAccount) {
      _updateIndicator(shouldShow: true);
      try {
        AuthResult result = await _authService.signInWithGoogle();
        if (result.additionalUserInfo.isNewUser) {
          User user = User("", "", result.user.displayName);
          _userService.updateUserData(result.user.uid, user);
        }
        yield LoginWithGoogleSuccessful(result.user);
      } catch (error) {
        print(error);
        yield LoginError("Something went wrong, try again");
      }
      _updateIndicator(shouldShow: false);
    }
  }
}
