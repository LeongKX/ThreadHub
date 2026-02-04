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
    setState(() {
      _titleError = _title.isEmpty ? "Title cannot be empty" : null;
      _contentError = _content.isEmpty ? "Content cannot be empty" : null;
    });

    if (_titleError != null || _contentError != null) return;

    setState(() => loading = true);

    try {
      final auth = AuthRepo();
      final authorId = auth.currentUserId;
      if (authorId == null) throw Exception("User not logged in");

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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add post: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      appBar: AppBar(
        title: const Text("Create Post"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// TITLE FIELD
                TextField(
                  onChanged: (v) => setState(() => _title = v),
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    hintText: "Enter post title",
                    hintStyle: const TextStyle(color: Colors.black45),
                    errorText: _titleError,
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// CONTENT FIELD
                TextField(
                  onChanged: (v) => setState(() => _content = v),
                  minLines: 6,
                  maxLines: 6,
                  textAlignVertical: TextAlignVertical.center,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Content",
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 18,
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    hintText: "Write something...",
                    hintStyle: const TextStyle(color: Colors.black45),
                    errorText: _contentError,
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.deepPurple,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// SUBMIT BUTTON
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : _onAddPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade700,
                      disabledBackgroundColor: Colors.grey.shade400,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "POST",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
