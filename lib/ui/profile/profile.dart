import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:threadhub/data/model/post.dart';
import 'package:threadhub/data/repo/auth_repo.dart';
import 'package:threadhub/data/repo/user_repo.dart';
import 'package:threadhub/ui/utils/profile_stat.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final auth = AuthRepo();
  final userRepo = UserRepo();

  @override
  Widget build(BuildContext context) {
    final userId = auth.currentUserId;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: userRepo.getUserProfile(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROFILE HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['username'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      data['email'],
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ProfileStat(
                          label: "Followers",
                          count: data['followersCount'],
                        ),
                        ProfileStat(
                          label: "Following",
                          count: data['followingCount'],
                        ),
                        StreamBuilder<int>(
                          stream: userRepo.getPostCount(userId),
                          builder: (context, snapshot) {
                            return ProfileStat(
                              label: "Posts",
                              count: snapshot.data ?? 0,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(),

              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "My Posts",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // OWN POSTS
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: userRepo.getOwnPosts(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final posts = snapshot.data ?? [];
                    if (posts.isEmpty) {
                      return const Center(child: Text("No posts yet"));
                    }

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final createdAt = post['createdAt'] as Timestamp;

                        return ListTile(
                          title: Text(post['title']),
                          subtitle: Text(
                            DateFormat(
                              'dd MMM yyyy',
                            ).format(createdAt.toDate()),
                          ),
                          onTap: () {
                            // Convert Firestore map to Post
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

                            // Navigate to PostDetailScreen
                            GoRouter.of(
                              context,
                            ).push('/post/${postObj.docId}', extra: postObj);
                          },
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
