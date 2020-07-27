import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  String id;
  Timestamp createdAt;
  Timestamp lastMessageAt;
  List<dynamic> participants;

  Chat(this.createdAt, this.participants);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['createdAt'] = createdAt;
    map['lastMessageAt'] = lastMessageAt;
    map['participants'] = participants;

    return map;
  }

  Chat.fromMap(Map<String, dynamic> data) {
    createdAt = data['createdAt'];
    lastMessageAt = data['lastMessageAt'];
    participants = data['participants'];
  }
}
