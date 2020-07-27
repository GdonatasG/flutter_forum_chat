import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterforum/bloc/register/register_bloc_export.dart';
import 'package:flutterforum/model/user.dart';
import 'package:flutterforum/services/auth_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:rxdart/rxdart.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthService _authService;
  final UserService _userService;

  RegisterBloc(this._authService, this._userService) : super(null);

  RegisterState get initialState => RegisterInitial();

  // Controlling progress indicator
  // false - indicator is hidden
  // true - email sending is in process, indicator is visible
  final _progressIndicatorController = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get progressIndicatorStream =>
      _progressIndicatorController.stream;

  _updateIndicator({bool shouldShow}) {
    _progressIndicatorController.value = shouldShow;
  }

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is RegisterUser) {
      _updateIndicator(shouldShow: true);
      try {
        AuthResult result = await _authService.createUserWithEmailAndPassword(
            event.email, event.password);
        await _userService.updateUserData(result.user.uid, event.user);
        await result.user
            .sendEmailVerification()
            .timeout(Duration(seconds: 15));
        yield RegisterSuccessful(
            result.user,
            event
                .user); // Sending FirebaseUser object and Firestore User object
      } catch (error) {
        print(error);
        yield RegisterError("Can't register! Try again");
      }
      _updateIndicator(shouldShow: false);
    }
  }
}
