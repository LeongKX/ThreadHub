import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadhub/data/model/post.dart';
import 'package:threadhub/ui/auth/signin.dart';
import 'package:threadhub/ui/auth/signup.dart';
import 'package:threadhub/ui/home/home.dart';
import 'package:threadhub/ui/post/add_post_screen.dart';
import 'package:threadhub/ui/post/post_detail_screen.dart';

class Nav {
  static const inintial = "/signup";
  static final routes = [
    GoRoute(
      path: "/signup",
      name: Screen.signup.name,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: "/signin",
      name: Screen.signin.name,
      builder: (context, state) => const SigninScreen(),
    ),
    GoRoute(
      path: "/home",
      name: Screen.home.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: "/addpost",
      name: Screen.addpost.name,
      builder: (context, state) => const AddPostScreen(),
    ),
    GoRoute(
      path: "/post/:postId",
      name: Screen.detailscreen.name,
      builder: (context, state) {
        final post = state.extra as Post?; // must pass the Post when navigating
        if (post == null) {
          return const Scaffold(body: Center(child: Text("Post not found")));
        }
        return PostDetailScreen(post: post);
      },
    ),
  ];
}

enum Screen { home, profile, signin, signup, addpost, detailscreen }
