import 'package:flutterforum/model/chat.dart';

abstract class UsersForChattingPageEvent {
  const UsersForChattingPageEvent();
}

class StartNewChat extends UsersForChattingPageEvent {
  final String uid1;
  final String uid2;
  final Chat chat;

  StartNewChat(this.uid1, this.uid2, this.chat);

  List<Object> get props => [uid1, uid2, chat];
}
