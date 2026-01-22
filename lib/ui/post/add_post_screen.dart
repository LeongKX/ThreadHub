import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadhub/data/model/post.dart';
import 'package:threadhub/data/repo/auth_repo.dart';
import 'package:threadhub/data/repo/post_repo.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final repo = PostRepo();
  String _title = "", _content = "";
  String? _titleError, _contentError;
  bool loading = false;

  void _onAddPressed() async {
    if (_title.isEmpty) {
      setState(() => _titleError = "Title cannot be empty");
      return;
    }
    if (_content.isEmpty) {
      setState(() => _contentError = "Content cannot be empty");
      return;
    }

    setState(() => loading = true);

    try {
      final auth = AuthRepo();
      final authorId = auth.currentUserId;

      if (authorId == null) {
        throw Exception("User not logged in");
      }

      final username = await auth.getCurrentUsername();

      final post = Post.create(
        title: _title,
        content: _content,
        authorId: authorId,
        authorName: username,
      );

      await repo.addPost(post);

      if (mounted) context.pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add post: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Feed")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => setState(() => _title = v),
              decoration: InputDecoration(
                hintText: "Enter title",
                errorText: _titleError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              onChanged: (v) => setState(() => _content = v),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Enter content",
                errorText: _contentError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: loading ? null : _onAddPressed,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}
