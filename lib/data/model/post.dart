import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String docId;
  final String title;
  final String content;
  final String authorId;
  final String authorName; // add authorName
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;
  final List<String> upvotedBy;
  final List<String> downvotedBy;

  Post({
    required this.docId,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName, // required
    required this.upvotes,
    required this.downvotes,
    required this.createdAt,
    this.upvotedBy = const [],
    this.downvotedBy = const [],
  });

  Post copyWith({
    String? docId,
    String? title,
    String? content,
    String? authorId,
    String? authorName,
    int? upvotes,
    int? downvotes,
    DateTime? createdAt,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
  }) {
    return Post(
      docId: docId ?? this.docId,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      createdAt: createdAt ?? this.createdAt,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
    );
  }

  factory Post.create({
    required String title,
    required String content,
    required String authorId,
    required String authorName,
  }) {
    return Post(
      docId: "",
      title: title,
      content: content,
      authorId: authorId,
      authorName: authorName,
      upvotes: 0,
      downvotes: 0,
      createdAt: DateTime.now(),
      upvotedBy: [],
      downvotedBy: [],
    );
  }

  factory Post.fromMap(Map<String, dynamic> map, String docId) {
    return Post(
      docId: docId,
      title: map['title'] ?? "",
      content: map['content'] ?? "",
      authorId: map['authorId'] ?? "",
      authorName: map['authorName'] ?? "Unknown", // get from Firestore
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      upvotedBy: List<String>.from(map['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(map['downvotedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      "authorId": authorId,
      'authorName': authorName, // save username
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() {
    return '''Post(docId: $docId, title: $title, content: $content, authorName: $authorName, upvotes: $upvotes, downvotes: $downvotes, createdAt: $createdAt)''';
  }
}
