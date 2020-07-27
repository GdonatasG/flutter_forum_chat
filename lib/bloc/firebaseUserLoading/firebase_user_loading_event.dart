abstract class FirebaseUserLoadingEvent {
  const FirebaseUserLoadingEvent();
}

class LoadCurrentUser extends FirebaseUserLoadingEvent {
  LoadCurrentUser();

  List<Object> get props => [];
}

class SignOut extends FirebaseUserLoadingEvent {
  SignOut();

  List<Object> get props => [];
}
