import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:threadhub/data/model/post.dart';
import 'package:threadhub/data/repo/auth_repo.dart';
import 'package:threadhub/data/repo/user_repo.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final auth = AuthRepo();
  final userRepo = UserRepo();

  bool loading = false;

  Future<void> logout() async {
    setState(() => loading = true);

    try {
      await auth.logout();
      if (!mounted) return;
      context.go("/signin");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = auth.currentUserId;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: loading ? null : logout,
            icon: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userRepo.getUserProfile(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return Column(
            children: [
              // 🔵 HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.deepPurpleAccent],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Text(
                        data['username'][0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['username'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      data['email'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 📊 STATS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard(
                      label: "Followers",
                      count: data['followersCount'],
                    ),
                    _StatCard(
                      label: "Following",
                      count: data['followingCount'],
                    ),
                    StreamBuilder<int>(
                      stream: userRepo.getPostCount(userId),
                      builder: (context, snapshot) {
                        return _StatCard(
                          label: "Posts",
                          count: snapshot.data ?? 0,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🧵 POSTS TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "My Posts",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // 🧵 POSTS LIST
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: userRepo.getOwnPosts(userId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final posts = snapshot.data!;
                    if (posts.isEmpty) {
                      return const Center(child: Text("No posts yet"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final createdAt = post['createdAt'] as Timestamp;

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(
                              post['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat(
                                'dd MMM yyyy',
                              ).format(createdAt.toDate()),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              final postObj = Post(
                                docId: post['docId'],
                                authorId: post['authorId'],
                                authorName: post['authorName'],
                                title: post['title'],
                                content: post['content'],
                                upvotes: post['upvotes'] ?? 0,
                                downvotes: post['downvotes'] ?? 0,
                                upvotedBy: List<String>.from(
                                  post['upvotedBy'] ?? [],
                                ),
                                downvotedBy: List<String>.from(
                                  post['downvotedBy'] ?? [],
                                ),
                                createdAt: createdAt.toDate(),
                              );

                              context.push(
                                '/post/${postObj.docId}',
                                extra: postObj,
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;

  const _StatCard({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
