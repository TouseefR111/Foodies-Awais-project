import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';

import '../auth/login_screen.dart';
import 'my_bottom_nav.dart';
class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  User? user = FirebaseAuth.instance.currentUser;

  checkUser(BuildContext context){
    if(user != null){
      return const LoginScreen();
    }
    else{
      return const MyBottomNav();
    }

  }

  @override
  Widget build(BuildContext context) {
    return const CheckUser();
  }
}
