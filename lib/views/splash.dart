import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/auth/login_screen.dart';
import 'package:food_delivery_app/main.dart';
import 'package:food_delivery_app/views/check_user.dart';
import 'package:food_delivery_app/views/home_screen.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';
import 'package:sizer/sizer.dart';

import 'my_bottom_nav.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.amber),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png"),
            Text(
              "Foodies",
              style: TextStyle(
                fontSize: 45.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.black,
                fontFamily: 'Playwrite',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
