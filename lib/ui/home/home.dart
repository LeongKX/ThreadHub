import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:threadhub/data/model/post.dart';
import 'package:threadhub/data/repo/auth_repo.dart';
import 'package:threadhub/data/repo/post_repo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = false;

  void logout() async {
    setState(() => loading = true);
    try {
      await AuthRepo().logout();
      if (mounted) context.go("/signin");
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthRepo().currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ThreadHub"),
        actions: [
          IconButton(
            onPressed: loading ? null : logout,
            icon: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Feed",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Post>>(
                stream: PostRepo().getAllPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  }

                  final posts = snapshot.data ?? [];

                  if (posts.isEmpty) {
                    return const Center(child: Text("No posts yet"));
                  }

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];

                      final formattedDate = DateFormat(
                        'yyyy-MM-dd – kk:mm',
                      ).format(post.createdAt);

                      final hasUpvoted = post.upvotedBy.contains(currentUserId);
                      final hasDownvoted = post.downvotedBy.contains(
                        currentUserId,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    post.authorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                post.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(post.content),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.thumb_up, size: 18),
                                    color: hasUpvoted ? Colors.green : null,
                                    onPressed: () {
                                      if (currentUserId != null) {
                                        PostRepo().upvote(
                                          post.docId,
                                          currentUserId,
                                        );
                                      }
                                    },
                                  ),
                                  Text(post.upvotes.toString()),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.thumb_down,
                                      size: 18,
                                    ),
                                    color: hasDownvoted ? Colors.red : null,
                                    onPressed: () {
                                      if (currentUserId != null) {
                                        PostRepo().downvote(
                                          post.docId,
                                          currentUserId,
                                        );
                                      }
                                    },
                                  ),
                                  Text(post.downvotes.toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push("/addpost");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
