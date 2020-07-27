import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String id;
  String ownerId;
  String postId;
  String content;
  Timestamp createdAt;
  bool isEdited;
  Timestamp editedAt;

  Comment(this.ownerId, this.postId, this.content, this.createdAt,
      this.isEdited, this.editedAt);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['ownerId'] = ownerId;
    map['postId'] = postId;
    map['content'] = content;
    map['createdAt'] = createdAt;
    map['isEdited'] = isEdited;
    map['editedAt'] = editedAt;

    return map;
  }

  Comment.fromMap(Map<String, dynamic> data) {
    ownerId = data['ownerId'];
    postId = data['postId'];
    content = data['content'];
    createdAt = data['createdAt'];
    isEdited = data['isEdited'];
    editedAt = data['editedAt'];
  }
}
