import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterforum/services/auth_service.dart';

import 'firebase_user_loading_bloc_export.dart';

class FirebaseUserLoadingBloc
    extends Bloc<FirebaseUserLoadingEvent, FirebaseUserLoadingState> {
  final AuthService _authService;

  FirebaseUserLoadingBloc(this._authService) : super(null);

  FirebaseUserLoadingState get initialState => FirebaseUserLoadingInitial();

  @override
  Stream<FirebaseUserLoadingState> mapEventToState(
      FirebaseUserLoadingEvent event) async* {
    if (event is LoadCurrentUser) {
      try {
        FirebaseUser user =
            await _authService.loadCurrentUser().timeout(Duration(seconds: 15));
        yield FirebaseUserLoaded(user);
      } catch (error) {
        print(error);
        yield FirebaseUserLoadingError("Can't load user!");
      }
    } else if (event is SignOut) {
      try {
        await _authService.signOut();
        yield FirebaseUserLoadingSignOutSuccessful();
      } catch (error) {
        print(error);
        yield FirebaseUserLoadingSignOutError("Something went wrong!");
      }
    }
  }
}
