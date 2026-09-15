// ...existing code...
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/admin/admin_login.dart';
import 'package:food_delivery_app/views/check_user.dart';
import 'package:sizer/sizer.dart';

import '../auth/login_screen.dart';
import '../views/my_bottom_nav.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  Widget checkUser(BuildContext context) {
    return user != null ? const MyBottomNav() : const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade200,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade200, Colors.amber.shade400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 700),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "FOODIES",
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                        fontFamily: 'Playwrite',
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: 34.w,
                          height: 34.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    SizedBox(
                      width: double.infinity,
                      height: 7.h,
                      child: ElevatedButton(
                        onPressed: () {
                          final dest = checkUser(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => dest),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amberAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "LOGIN AS USER",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: double.infinity,
                      height: 7.h,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminLogin(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.black12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "LOGIN AS ADMIN",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black54,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
