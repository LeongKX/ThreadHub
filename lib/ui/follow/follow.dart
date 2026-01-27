import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadhub/data/repo/auth_repo.dart';
import 'package:threadhub/data/repo/user_repo.dart';

class DiscoverUsersScreen extends StatefulWidget {
  const DiscoverUsersScreen({super.key});

  @override
  State<DiscoverUsersScreen> createState() => _DiscoverUsersScreenState();
}

class _DiscoverUsersScreenState extends State<DiscoverUsersScreen> {
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
    final currentUserId = auth.currentUserId;

    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Discover Users"),
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: userRepo.getAllOtherUsers(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return ListTile(
                title: Text(user['username']),
                subtitle: Text(user['email']),
                trailing: StreamBuilder<bool>(
                  stream: userRepo.isFollowing(currentUserId, user['userId']),
                  builder: (context, snapshot) {
                    final isFollowing = snapshot.data ?? false;

                    return ElevatedButton(
                      onPressed: () {
                        if (isFollowing) {
                          userRepo.unfollowUser(currentUserId, user['userId']);
                        } else {
                          userRepo.followUser(currentUserId, user['userId']);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing
                            ? Colors.grey[300]
                            : Colors.blue,
                      ),
                      child: Text(
                        isFollowing ? "Unfollow" : "Follow",
                        style: TextStyle(
                          color: isFollowing ? Colors.black : Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
