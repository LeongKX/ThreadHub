import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../model/user.dart';

class AuthRepo {
  static final AuthRepo _instance = AuthRepo._internal();
  AuthRepo._internal();
  factory AuthRepo() => _instance;

  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final _users = FirebaseFirestore.instance.collection("users");

  Future<fb.UserCredential> signUp(User user) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );

    await _users.doc(cred.user!.uid).set(user.toMap());

    return cred;
  }

  Future<fb.UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() => _auth.signOut();

  String? get currentUserId => _auth.currentUser?.uid;

  /// NEW: Get current user's username from Firestore
  Future<String?> get currentUsername async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;

    return (doc.data()!['username'] ?? "Unknown") as String;
  }
}
