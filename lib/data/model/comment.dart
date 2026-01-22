import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String docId;
  final String postId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.docId,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  /// Factory to create a new comment (createdAt set automatically)
  factory Comment.create({
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
  }) {
    return Comment(
      docId: "",
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      content: content,
      createdAt: DateTime.now(),
    );
  }

  /// Convert Firestore map to Comment
  factory Comment.fromMap(Map<String, dynamic> map, String docId) {
    final timestamp = map['createdAt'];
    return Comment(
      docId: docId,
      postId: map['postId'] ?? "",
      authorId: map['authorId'] ?? "",
      authorName: map['authorName'] ?? "Unknown",
      content: map['content'] ?? "",
      createdAt: timestamp != null
          ? (timestamp as Timestamp).toDate()
          : DateTime.now(), // fallback to now if null
    );
  }

  /// Convert Comment to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with new content
  Comment copyWith({String? content}) {
    return Comment(
      docId: docId,
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      content: content ?? this.content,
      createdAt: createdAt,
    );
  }
}
