import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterforum/model/user.dart';

class UserService {
  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  Future<void> updateUserData(String uid, User user) async {
    return await userCollection
        .document(uid)
        .setData(user.toMap())
        .timeout(Duration(seconds: 15));
  }

  Query getAllUsers() => userCollection;

  DocumentReference getFirestoreUserById(String uid) =>
      userCollection.document(uid);
}
