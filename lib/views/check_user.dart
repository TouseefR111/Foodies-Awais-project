import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';

import '../auth/login_screen.dart';
import 'my_bottom_nav.dart';

// ...existing code...
class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Widget _resolve() {
    // return home when user is signed in, otherwise login
    return user != null ? const MyBottomNav() : const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return _resolve();
  }
}
