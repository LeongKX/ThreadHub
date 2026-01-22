import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:threadhub/data/model/post.dart';
import 'package:threadhub/data/model/comment.dart';
import 'package:threadhub/data/repo/auth_repo.dart';
import 'package:threadhub/data/repo/post_repo.dart';
import 'package:threadhub/data/repo/comment_repo.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final auth = AuthRepo();
  final postRepo = PostRepo();
  final commentRepo = CommentRepo();
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentUserId = auth.currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Detail"),
        actions: [
          // Edit/Delete buttons only for post author
          StreamBuilder<Post?>(
            stream: postRepo.getPostByIdStream(widget.post.docId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Container();
              final post = snapshot.data!;
              final isPostAuthor = post.authorId == currentUserId;

              if (!isPostAuthor) return Container();

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await showDialog<Post>(
                        context: context,
                        builder: (_) {
                          final titleCtrl = TextEditingController(
                            text: post.title,
                          );
                          final contentCtrl = TextEditingController(
                            text: post.content,
                          );
                          return AlertDialog(
                            title: const Text("Edit Post"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: titleCtrl,
                                  decoration: const InputDecoration(
                                    labelText: "Title",
                                  ),
                                ),
                                TextField(
                                  controller: contentCtrl,
                                  decoration: const InputDecoration(
                                    labelText: "Content",
                                  ),
                                  maxLines: 5,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final updatedPost = post.copyWith(
                                    title: titleCtrl.text,
                                    content: contentCtrl.text,
                                  );
                                  Navigator.pop(context, updatedPost);
                                },
                                child: const Text("Save"),
                              ),
                            ],
                          );
                        },
                      );

                      if (result != null) {
                        await postRepo.updatePost(result);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Post"),
                          content: const Text(
                            "Are you sure you want to delete this post?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await postRepo.deletePost(widget.post.docId);
                        if (mounted) Navigator.pop(context);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<Post?>(
        stream: postRepo.getPostByIdStream(widget.post.docId),
        builder: (context, postSnapshot) {
          if (!postSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = postSnapshot.data!;
          final isPostAuthor = post.authorId == currentUserId;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AUTHOR + DATE
                Text(
                  "${post.authorName} • ${DateFormat('dd MMM yyyy, hh:mm a').format(post.createdAt)}",
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),

                // TITLE
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // CONTENT
                Text(post.content),
                const SizedBox(height: 16),

                // UPVOTE / DOWNVOTE
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up),
                      color: post.upvotedBy.contains(currentUserId)
                          ? Colors.green
                          : null,
                      onPressed: currentUserId == null
                          ? null
                          : () async {
                              await postRepo.upvote(post.docId, currentUserId);
                            },
                    ),
                    Text(post.upvotes.toString()),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.thumb_down),
                      color: post.downvotedBy.contains(currentUserId)
                          ? Colors.red
                          : null,
                      onPressed: currentUserId == null
                          ? null
                          : () async {
                              await postRepo.downvote(
                                post.docId,
                                currentUserId,
                              );
                            },
                    ),
                    Text(post.downvotes.toString()),
                  ],
                ),

                const Divider(),
                const Text(
                  "Comments",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // COMMENTS LIST
                Expanded(
                  child: StreamBuilder<List<Comment>>(
                    stream: commentRepo.getComments(post.docId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final comments = snapshot.data!;
                      if (comments.isEmpty) {
                        return const Center(child: Text("No comments yet"));
                      }

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final c = comments[index];
                          final isCommentAuthor = c.authorId == currentUserId;

                          return ListTile(
                            title: Text(
                              c.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(c.content),
                            trailing: isCommentAuthor
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await commentRepo.deleteComment(
                                        post.docId,
                                        c.docId,
                                      );
                                    },
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),

                // ADD COMMENT
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentCtrl,
                        decoration: const InputDecoration(
                          hintText: "Write a comment...",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: currentUserId == null
                          ? null
                          : () async {
                              if (_commentCtrl.text.trim().isEmpty) return;

                              final username = await auth
                                  .getCurrentUsername(); // await future
                              final comment = Comment.create(
                                postId: post.docId,
                                content: _commentCtrl.text.trim(),
                                authorId: currentUserId,
                                authorName: username ?? "Unknown",
                              );

                              await commentRepo.addComment(comment);
                              _commentCtrl.clear();
                            },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
