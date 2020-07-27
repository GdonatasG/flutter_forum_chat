import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterforum/model/chat_message.dart';
import 'package:flutterforum/services/chat_service.dart';
import 'package:flutterforum/services/user_service.dart';

class ChatPageBloc {
  final ChatService _chatService;
  final UserService _userService;

  ChatPageBloc(this._chatService, this._userService);

  Future<DocumentSnapshot> getFirestoreUser(String uid) async =>
      _userService.getFirestoreUserById(uid).get();

  Stream<DocumentSnapshot> streamFirestoreUser(String uid) =>
      _userService.getFirestoreUserById(uid).snapshots();

  Stream<DocumentSnapshot> getChatById(String chatId) =>
      _chatService.getChatById(chatId).snapshots();

  Stream<QuerySnapshot> getMoreChatMessages(String chatId, int limit) =>
      _chatService
          .getChatMessagesCollection(chatId)
          .orderBy('sentAt', descending: true)
          .limit(limit)
          .snapshots();

  Stream<QuerySnapshot> checkForChatMessageUpdates(String chatId) =>
      _chatService
          .getChatMessagesCollection(chatId)
          .orderBy('sentAt', descending: true)
          .limit(1)
          .snapshots();

  Future<QuerySnapshot> getPreviousChatMessages(
          String chatId, Timestamp before, int limit) =>
      _chatService
          .getChatMessagesCollection(chatId)
          .where('sentAt', isLessThan: before)
          .orderBy('sentAt', descending: true)
          .limit(limit)
          .getDocuments();

  Future<DocumentReference> addNewMessage(String chatId, ChatMessage message) =>
      _chatService.getChatMessagesCollection(chatId).add(message.toMap());

  Future<void> markMessageAsSent(String chatId, ChatMessage message) =>
      _chatService
          .getChatMessagesCollection(chatId)
          .document(message.id)
          .updateData(message.toMap());

  Future<void> updateLastChatMessageTime(
          String chatId, Timestamp lastMessageAt) =>
      _chatService
          .getChatById(chatId)
          .setData({"lastMessageAt": lastMessageAt}, merge: true);
}
