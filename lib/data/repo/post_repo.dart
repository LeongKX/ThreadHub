import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/post.dart';

class PostRepo {
  static final PostRepo _instance = PostRepo._internal();
  PostRepo._internal();
  factory PostRepo() => _instance;

  final _collection = FirebaseFirestore.instance.collection("posts");

  Stream<List<Post>> getAllPosts() {
    return _collection
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Post.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<Post?> getPostById(String docId) async {
    final res = await _collection.doc(docId).get();
    if (!res.exists || res.data() == null) return null;
    return Post.fromMap(res.data()!, res.id);
  }

  Future<void> addPost(Post post) async {
    await _collection.add(post.toMap());
  }

  Future<void> updatePost(Post post) async {
    await _collection.doc(post.docId).update(post.toMap());
  }

  Future<void> deletePost(String docId) async {
    await _collection.doc(docId).delete();
  }

  Stream<Post?> getPostByIdStream(String docId) {
    return _collection.doc(docId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return Post.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  /// Transactional upvote
  Future<void> upvote(String postId, String userId) async {
    final ref = _collection.doc(postId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final data = snap.data()!;
      final List<String> upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
      final List<String> downvotedBy = List<String>.from(
        data['downvotedBy'] ?? [],
      );
      int upvotes = data['upvotes'] ?? 0;
      int downvotes = data['downvotes'] ?? 0;

      if (upvotedBy.contains(userId)) {
        // Remove existing upvote
        upvotedBy.remove(userId);
        upvotes--;
      } else {
        // Add upvote
        upvotedBy.add(userId);
        upvotes++;

        // Remove downvote if exists
        if (downvotedBy.contains(userId)) {
          downvotedBy.remove(userId);
          downvotes--;
        }
      }

      tx.update(ref, {
        'upvotes': upvotes,
        'downvotes': downvotes,
        'upvotedBy': upvotedBy,
        'downvotedBy': downvotedBy,
      });
    });
  }

  /// Transactional downvote
  Future<void> downvote(String postId, String userId) async {
    final ref = _collection.doc(postId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final data = snap.data()!;
      final List<String> upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
      final List<String> downvotedBy = List<String>.from(
        data['downvotedBy'] ?? [],
      );
      int upvotes = data['upvotes'] ?? 0;
      int downvotes = data['downvotes'] ?? 0;

      if (downvotedBy.contains(userId)) {
        // Remove existing downvote
        downvotedBy.remove(userId);
        downvotes--;
      } else {
        // Add downvote
        downvotedBy.add(userId);
        downvotes++;

        // Remove upvote if exists
        if (upvotedBy.contains(userId)) {
          upvotedBy.remove(userId);
          upvotes--;
        }
      }

      tx.update(ref, {
        'upvotes': upvotes,
        'downvotes': downvotes,
        'upvotedBy': upvotedBy,
        'downvotedBy': downvotedBy,
      });
    });
  }
}
