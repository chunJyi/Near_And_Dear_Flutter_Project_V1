import 'package:flutter/material.dart';
import 'package:near_and_dear_flutter_v1/providers/user_provider.dart';
import 'package:near_and_dear_flutter_v1/screens/auth_screen/auth_screen.dart';
import 'package:near_and_dear_flutter_v1/screens/home_screen/home_screen.dart';
import 'package:provider/provider.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.user;
    if (currentUser != null) {
      return const HomeScreen();
    }
    return const AuthScreen();
  }
}
