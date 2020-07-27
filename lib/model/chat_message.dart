import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  String id;
  String content;
  Timestamp sentAt;
  String sentBy;
  bool isSent = false;

  ChatMessage(this.content, this.sentAt, this.sentBy);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['content'] = content;
    map['sentAt'] = sentAt;
    map['sentBy'] = sentBy;
    map['isSent'] = isSent;

    return map;
  }

  ChatMessage.fromMap(Map<String, dynamic> data) {
    content = data['content'];
    sentAt = data['sentAt'];
    sentBy = data['sentBy'];
    isSent = data['isSent'];
  }
}
