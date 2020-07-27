import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final CollectionReference categoryCollection =
      Firestore.instance.collection('categories');

  CollectionReference getCategories() => categoryCollection;
}
