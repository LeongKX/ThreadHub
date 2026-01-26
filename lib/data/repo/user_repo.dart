import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepo {
  final _firestore = FirebaseFirestore.instance;
  final _users = FirebaseFirestore.instance.collection("users");
  final _followers = FirebaseFirestore.instance.collection("followers");
  final _posts = FirebaseFirestore.instance.collection("posts");

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final userSnap = await _users.doc(userId).get();
    final followSnap = await _followers.doc(userId).get();

    final followers = followSnap.data()?['followers'] ?? [];
    final following = followSnap.data()?['following'] ?? [];

    return {
      "username": userSnap.data()?['username'] ?? "Unknown",
      "email": userSnap.data()?['email'] ?? "",
      "followersCount": followers.length,
      "followingCount": following.length,
    };
  }

  Stream<int> getPostCount(String userId) {
    return _posts
        .where("authorId", isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  Stream<List<Map<String, dynamic>>> getOwnPosts(String userId) {
    return _posts
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            // Ensure createdAt exists and is Timestamp
            final createdAt = data['createdAt'] as Timestamp?;
            return {
              'docId': doc.id,
              'title': data['title'] ?? 'No title',
              'createdAt': createdAt ?? Timestamp.now(),
              ...data,
            };
          }).toList();
        });
  }
}
