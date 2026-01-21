import 'package:go_router/go_router.dart';
import 'package:threadhub/ui/auth/signin.dart';
import 'package:threadhub/ui/auth/signup.dart';
import 'package:threadhub/ui/home/home.dart';
import 'package:threadhub/ui/post/add_post_screen.dart';

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
  ];
}

enum Screen { home, profile, signin, signup, addpost }
