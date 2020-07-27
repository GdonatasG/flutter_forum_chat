import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterforum/model/chat.dart';

class ChatService {
  final CollectionReference chatCollection =
      Firestore.instance.collection('chats');

  Query getUserChats(String uid) => chatCollection
      .where('participants', arrayContains: uid)
      .orderBy('lastMessageAt', descending: true);

  CollectionReference getChatMessagesCollection(String chatId) =>
      chatCollection.document(chatId).collection('messages');

  DocumentReference getChatById(String chatId) =>
      chatCollection.document(chatId);

  Future<void> addNewOneToOneChat(Chat c) async => await chatCollection
      .document(c.id)
      .setData(c.toMap())
      .timeout(Duration(seconds: 15));
}
