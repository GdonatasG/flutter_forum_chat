import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterforum/services/chat_service.dart';
import 'package:flutterforum/services/user_service.dart';

class UserChatsPageBloc {
  final ChatService _chatService;
  final UserService _userService;

  UserChatsPageBloc(this._chatService, this._userService);

  Stream<QuerySnapshot> getUserChats(String uid) =>
      _chatService.getUserChats(uid).snapshots().timeout(Duration(seconds: 15));

  Future<DocumentSnapshot> getFirestoreUser(String uid) async =>
      _userService.getFirestoreUserById(uid).get();

  Stream<QuerySnapshot> getLastChatMessage(String chatId) => _chatService
      .getChatMessagesCollection(chatId)
      .orderBy('sentAt', descending: true)
      .limit(1)
      .snapshots();
}
