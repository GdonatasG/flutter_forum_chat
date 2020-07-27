import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterforum/bloc/add_post_page/add_post_page_bloc_export.dart';
import 'package:flutterforum/services/auth_service.dart';
import 'package:flutterforum/services/post_service.dart';
import 'package:flutterforum/utils/extensions.dart';
import 'package:rxdart/rxdart.dart';

class AddPostPageBloc extends Bloc<AddPostPageEvent, AddPostPageState> {
  final PostService _postService;
  final AuthService _authService;

  // Controlling progress indicator
  // false - indicator is hidden
  // true - indicator is visible
  final _progressIndicatorController = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get progressIndicatorStream =>
      _progressIndicatorController.stream;

  _updateIndicator({bool shouldShow}) {
    _progressIndicatorController.value = shouldShow;
  }

  AddPostPageBloc(this._postService, this._authService) : super(null);

  @override
  AddPostPageState get initialState => AddPostPageInitial();

  @override
  Stream<AddPostPageState> mapEventToState(AddPostPageEvent event) async* {
    if (event is ReloadCurrentUser) {
      _updateIndicator(shouldShow: true);
      try {
        FirebaseUser user =
            await _authService.loadCurrentUser().timeout(Duration(seconds: 15));
        yield AddPostPageFirebaseUserLoaded(user);
      } catch (error) {
        print(error);
        yield AddPostPageFirebaseUserLoadingError(
            "Something went wrong. Check your internet connection!");
      }
      _updateIndicator(shouldShow: false);
    } else if (event is AddPostIntoFirestore) {
      _updateIndicator(shouldShow: true);
      try {
        if (await hasInternet()) {
          DocumentReference documentOfNewPost = await _postService
              .addNewPost(event.post)
              .timeout(Duration(seconds: 15));
          yield AddPostPagePostAdded(documentOfNewPost.documentID);
        } else
          yield AddPostPageNoInternet("Check your internet connection!");
      } catch (error) {
        print(error);
        yield AddPostPagePostingError("Something went wrong. Try again!");
      }
      _updateIndicator(shouldShow: false);
    }
  }
}
