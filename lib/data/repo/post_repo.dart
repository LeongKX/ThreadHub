import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:threadhub/data/model/post.dart';

class PostRepo {
  static final PostRepo _instance = PostRepo._internal();
  PostRepo._internal();

  factory PostRepo() {
    return _instance;
  }

  final _collection = FirebaseFirestore.instance.collection("posts");

  Stream<List<Post>> getAllPosts() {
    return _collection.snapshots().map((event) {
      return event.docs.map((doc) {
        return Post.fromMap(doc.data()).copy(docId: doc.id);
      }).toList();
    });
  }

  Future<Post?> getPostById(String docId) async {
    final res = await _collection.doc(docId).get();
    if (res.data() == null) {
      return null;
    }
    return Post.fromMap(res.data()!).copy(docId: res.id);
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
}