import 'package:cloud_firestore/cloud_firestore.dart';

class CRUDmethods {
  CollectionReference dbref =
      FirebaseFirestore.instance.collection('userBlogPosts');

  Future<void> addData(postData) {
    return dbref
        .add(postData)
        .then((value) => print("Post Added"))
        .catchError((error) => print("Failed to add post: $error"));
  }

  Future<QuerySnapshot> getData() {
    return dbref.get();
  }
}
