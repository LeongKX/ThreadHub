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

  /// Only the user who wrote the comment can delete it
  bool canDelete(Comment comment, String currentUserId) {
    return comment.authorId == currentUserId;
  }

  Future<void> _confirmAndDeleteComment(Post post, Comment c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Comment?"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await commentRepo.deleteComment(post.docId, c.docId);
    }
  }

  Future<void> _confirmAndDeletePost(Post post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Post?"),
        content: const Text("This will permanently delete the post."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await postRepo.deletePost(post.docId);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _showEditPostDialog(Post post) async {
    final titleCtrl = TextEditingController(text: post.title);
    final contentCtrl = TextEditingController(text: post.content);

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Post"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              decoration: const InputDecoration(labelText: "Content"),
              minLines: 3,
              maxLines: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (saved == true) {
      final newTitle = titleCtrl.text.trim();
      final newContent = contentCtrl.text.trim();
      if (newTitle.isEmpty || newContent.isEmpty) return;

      final updated = Post(
        docId: post.docId,
        title: newTitle,
        content: newContent,
        authorId: post.authorId,
        authorName: post.authorName,
        createdAt: post.createdAt,
        upvotes: post.upvotes,
        downvotes: post.downvotes,
        upvotedBy: post.upvotedBy,
        downvotedBy: post.downvotedBy,
      );

      await postRepo.updatePost(updated);
    }

    titleCtrl.dispose();
    contentCtrl.dispose();
  }

  Widget _buildCommentInput(String? currentUserId, Post post) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentCtrl,
              decoration: InputDecoration(
                hintText: "Write a comment...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: currentUserId == null
                  ? null
                  : () async {
                      final text = _commentCtrl.text.trim();
                      if (text.isEmpty) return;

                      final username = await auth.getCurrentUsername();
                      final comment = Comment.create(
                        postId: post.docId,
                        content: text,
                        authorId: currentUserId,
                        authorName: username ?? "Unknown",
                      );

                      await commentRepo.addComment(comment);
                      _commentCtrl.clear();
                    },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = auth.currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        title: const Text("Post"),
        actions: [
          // Edit/Delete only for the post owner
          StreamBuilder<Post?>(
            stream: postRepo.getPostByIdStream(widget.post.docId),
            builder: (context, snapshot) {
              final post = snapshot.data;
              final isOwner =
                  post != null &&
                  currentUserId != null &&
                  post.authorId == currentUserId;

              if (!isOwner) return const SizedBox.shrink();

              return Row(
                children: [
                  IconButton(
                    tooltip: "Edit",
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditPostDialog(post!),
                  ),
                  IconButton(
                    tooltip: "Delete",
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmAndDeletePost(post!),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<Post?>(
        stream: postRepo.getPostByIdStream(widget.post.docId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final post = snapshot.data!;

          return Column(
            children: [
              /// SCROLLABLE POST + COMMENTS
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// POST CARD
                      Card(
                        margin: const EdgeInsets.all(12),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.deepPurple,
                                    child: Text(
                                      post.authorName[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        post.authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'dd MMM yyyy • hh:mm a',
                                        ).format(post.createdAt),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(post.content),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _VoteChip(
                                    icon: Icons.thumb_up,
                                    count: post.upvotes,
                                    color: Colors.green,
                                    active: post.upvotedBy.contains(
                                      currentUserId,
                                    ),
                                    onTap: () {
                                      if (currentUserId != null) {
                                        postRepo.upvote(
                                          post.docId,
                                          currentUserId,
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  _VoteChip(
                                    icon: Icons.thumb_down,
                                    count: post.downvotes,
                                    color: Colors.red,
                                    active: post.downvotedBy.contains(
                                      currentUserId,
                                    ),
                                    onTap: () {
                                      if (currentUserId != null) {
                                        postRepo.downvote(
                                          post.docId,
                                          currentUserId,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// COMMENTS HEADER
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Comments",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      /// COMMENTS LIST
                      StreamBuilder<List<Comment>>(
                        stream: commentRepo.getComments(post.docId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final comments = snapshot.data!;
                          if (comments.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text("No comments yet"),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final c = comments[index];
                              final isMe = c.authorId == currentUserId;
                              final isPostOwnerComment =
                                  c.authorId == post.authorId;

                              final showDelete =
                                  currentUserId != null &&
                                  canDelete(c, currentUserId);

                              return Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // For other people's comments, show icon on the left (if it applies)
                                    if (!isMe && showDelete)
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        iconSize: 18,
                                        tooltip: "Delete",
                                        onPressed: () =>
                                            _confirmAndDeleteComment(post, c),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                      ),

                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      constraints: const BoxConstraints(
                                        maxWidth: 280,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? Colors.deepPurple
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (!isMe)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  c.authorName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                if (isPostOwnerComment) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.deepPurple
                                                          .withOpacity(0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      "author",
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Colors.deepPurple,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          if (!isMe) const SizedBox(height: 4),
                                          Text(
                                            c.content,
                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // For my comments, show icon on the right
                                    if (isMe && showDelete)
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        iconSize: 18,
                                        tooltip: "Delete",
                                        onPressed: () =>
                                            _confirmAndDeleteComment(post, c),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              /// COMMENT INPUT
              _buildCommentInput(currentUserId, post),
            ],
          );
        },
      ),
    );
  }
}

class _VoteChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _VoteChip({
    required this.icon,
    required this.count,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? color : Colors.grey),
            const SizedBox(width: 4),
            Text(count.toString()),
          ],
        ),
      ),
    );
  }
}
