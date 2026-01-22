import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/comment.dart';

class CommentRepo {
  static final CommentRepo _instance = CommentRepo._internal();
  CommentRepo._internal();
  factory CommentRepo() => _instance;

  final _collection = FirebaseFirestore.instance.collection("comments");

  /// Stream comments for a specific post
  Stream<List<Comment>> getComments(String postId) {
    return _collection
        .where("postId", isEqualTo: postId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Comment.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Add comment
  Future<void> addComment(Comment comment) async {
    await _collection.add(comment.toMap());
  }

  /// Update comment
  Future<void> updateComment(
    String postId,
    String commentId,
    String newContent,
  ) async {
    await _collection.doc(commentId).update({'content': newContent});
  }

  /// Delete comment
  Future<void> deleteComment(String postId, String commentId) async {
    await _collection.doc(commentId).delete();
  }
}
