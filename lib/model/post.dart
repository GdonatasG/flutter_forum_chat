import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String categoryId;
  String title;
  String content;
  String ownerId;
  List<dynamic> listOfLikedBy;
  Timestamp createdAt;
  Timestamp updatedAt;

  Post(this.categoryId, this.title, this.content, this.ownerId,
      this.listOfLikedBy, this.createdAt, this.updatedAt);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['title'] = title;
    map['categoryId'] = categoryId;
    map['content'] = content;
    map['ownerId'] = ownerId;
    map['listOfLikedBy'] = listOfLikedBy;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;

    return map;
  }

  Post.fromMap(Map<String, dynamic> data) {
    title = data['title'];
    categoryId = data['categoryId'];
    content = data['content'];
    ownerId = data['ownerId'];
    listOfLikedBy = data['listOfLikedBy'];
    createdAt = data['createdAt'];
    updatedAt = data['updatedAt'];
  }
}
