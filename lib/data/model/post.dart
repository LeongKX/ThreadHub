class Post {
  final String docId;
  final String title;
  final String content;
  final int upvotes;
  final int downvotes;
  final DateTime createdAt;

  static const TABLE_NAME = "posts";

  Post({
    required this.docId,
    required this.title,
    required this.content,
    required this.upvotes,
    required this.downvotes,
    required this.createdAt,
  });

  Post copy({
    String? docId,
    String? title,
    String? content,
    int? upvotes,
    int? downvotes,
    DateTime? createdAt,
  }) {
    return Post(
      docId: docId ?? this.docId,
      title: title ?? this.title,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Post.fromMap(Map<String, dynamic> json) {
    return Post(
      docId: json['docId'] ?? "",
      title: json['title'] ?? "",
      content: json['content'] ?? "",
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'title': title,
      'content': content,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '''Post(docId: $docId, title: $title, content: $content, upvotes: $upvotes, downvotes: $downvotes, createdAt: $createdAt)''';
  }
}
