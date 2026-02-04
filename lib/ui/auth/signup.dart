import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadhub/data/model/user.dart';
import 'package:threadhub/data/repo/auth_repo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool loading = false;

  Future<void> signup() async {
    if (_password.text.trim() != _confirmPassword.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => loading = true);

    try {
      final user = User(
        username: _username.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      await AuthRepo().signUp(user);

      if (!mounted) return;
      context.go("/signin");
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Signup failed: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _username,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPassword,
              decoration: const InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                TextButton(
                  onPressed: () {
                    context.go("/signin");
                  },
                  child: const Text("Sign In"),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: loading ? null : signup,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
