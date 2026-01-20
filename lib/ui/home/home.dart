import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadhub/data/repo/auth_repo.dart';

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
              child: ListView.builder(
                itemCount: 10, // placeholder for posts
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("Post title $index"),
                      subtitle: Text("Post content goes here..."),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.thumb_up, size: 18, color: Colors.green),
                          SizedBox(width: 4),
                          Text("0"),
                          SizedBox(width: 16),
                          Icon(Icons.thumb_down, size: 18, color: Colors.red),
                          SizedBox(width: 4),
                          Text("0"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
