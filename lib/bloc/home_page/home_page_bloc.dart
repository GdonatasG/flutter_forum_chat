import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterforum/services/category_service.dart';
import 'package:flutterforum/services/user_service.dart';

class HomePageBloc {
  final UserService _userService;
  final CategoryService _categoryService;

  HomePageBloc(this._userService, this._categoryService);

  Stream<DocumentSnapshot> streamFirestoreUser(String uid) =>
      _userService.getFirestoreUserById(uid).snapshots();

  Stream<QuerySnapshot> getCategories() =>
      _categoryService.getCategories().snapshots();
}
