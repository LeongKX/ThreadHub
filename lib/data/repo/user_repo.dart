import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:threadhub/data/model/user.dart';

class UserRepo {
  static final UserRepo _instance = UserRepo._internal();
  UserRepo._internal();

  factory UserRepo() {
    return _instance;
  }

  final _collection = FirebaseFirestore.instance.collection("users");

  Stream<List<User>> getAllUsers() {
    return _collection.snapshots().map((event) {
      return event.docs.map((doc) {
        return User.fromMap(doc.data()).copy(docId: doc.id);
      }).toList();
    });
  }

  Future<User?> getUserById(String docId) async {
    final res = await _collection.doc(docId).get();
    if (res.data() == null) {
      return null;
    }
    return User.fromMap(res.data()!).copy(docId: res.id);
  }
}
