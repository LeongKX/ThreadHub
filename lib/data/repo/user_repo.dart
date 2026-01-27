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

  /// 🔹 Get all users except current user
  Stream<List<Map<String, dynamic>>> getAllOtherUsers(String currentUserId) {
    return _users.snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUserId) // 🚫 prevent self
          .map((doc) {
            return {
              'userId': doc.id,
              'username': doc['username'],
              'email': doc['email'],
            };
          })
          .toList();
    });
  }

  /// 🔹 Check if current user already follows target user
  Stream<bool> isFollowing(String currentUserId, String targetUserId) {
    return _followers.doc(currentUserId).snapshots().map((doc) {
      final following = List<String>.from(doc.data()?['following'] ?? []);
      return following.contains(targetUserId);
    });
  }

  /// 🔹 Follow user
  Future<void> followUser(String currentUserId, String targetUserId) async {
    if (currentUserId == targetUserId) return; // 🚫 double safety

    final batch = _firestore.batch();

    final currentUserRef = _followers.doc(currentUserId);
    final targetUserRef = _followers.doc(targetUserId);

    batch.set(currentUserRef, {
      'following': FieldValue.arrayUnion([targetUserId]),
    }, SetOptions(merge: true));

    batch.set(targetUserRef, {
      'followers': FieldValue.arrayUnion([currentUserId]),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  /// 🔹 Unfollow user
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    batch.update(_followers.doc(currentUserId), {
      'following': FieldValue.arrayRemove([targetUserId]),
    });

    batch.update(_followers.doc(targetUserId), {
      'followers': FieldValue.arrayRemove([currentUserId]),
    });

    await batch.commit();
  }
}
