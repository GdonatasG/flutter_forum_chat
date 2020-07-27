import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterforum/bloc/users_for_chatting_page/users_for_chatting_page_bloc_export.dart';
import 'package:flutterforum/model/chat.dart';
import 'package:flutterforum/services/chat_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:flutterforum/utils/extensions.dart';
import 'package:rxdart/rxdart.dart';

class UsersForChattingPageBloc
    extends Bloc<UsersForChattingPageEvent, UsersForChattingPageState> {
  final UserService _userService;
  final ChatService _chatService;

  UsersForChattingPageState get initialState => UsersForChattingPageInitial();

  UsersForChattingPageBloc(this._userService, this._chatService) : super(null);

  // Controlling progress indicator
  // false - indicator is hidden
  // true - indicator is visible
  final _progressIndicatorController = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get progressIndicatorStream =>
      _progressIndicatorController.stream;

  _updateIndicator({bool shouldShow}) {
    _progressIndicatorController.value = shouldShow;
  }

  Stream<QuerySnapshot> getAvailableChatUsers() =>
      _userService.getAllUsers().snapshots();

  @override
  Stream<UsersForChattingPageState> mapEventToState(
      UsersForChattingPageEvent event) async* {
    if (event is StartNewChat) {
      _updateIndicator(shouldShow: true);
      if (await hasInternet()) {
        try {
          DocumentSnapshot attempt1 = await _chatService
              .getChatById(event.uid1 + event.uid2)
              .get()
              .timeout(Duration(seconds: 15));
          if (attempt1.exists)
            yield ChatAlreadyExists(attempt1.documentID);
          else {
            DocumentSnapshot attempt2 = await _chatService
                .getChatById(event.uid2 + event.uid1)
                .get()
                .timeout(Duration(seconds: 15));
            if (attempt2.exists)
              yield ChatAlreadyExists(attempt2.documentID);
            else {
              Chat c = event.chat;
              c.id = event.uid1 + event.uid2;
              await _chatService.addNewOneToOneChat(c);
              yield ChatSuccessfullyCreated(c.id);
            }
          }
        } catch (_) {
          yield NoInternet("Something went wrong! Check your internet");
        }
      } else
        yield NoInternet("Something went wrong! Check your internet");

      _updateIndicator(shouldShow: false);
    }
  }
}
