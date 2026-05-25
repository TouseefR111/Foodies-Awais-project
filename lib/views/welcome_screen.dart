import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/admin/admin_login.dart';
import 'package:food_delivery_app/auth/signup_screen.dart';
import 'package:food_delivery_app/views/check_user.dart';
import 'package:sizer/sizer.dart';

import '../auth/login_screen.dart';
import 'my_bottom_nav.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  User? user = FirebaseAuth.instance.currentUser;

  checkUser(BuildContext context){
    if(user != null){
      return const MyBottomNav();
    }
    else{
      return const LoginScreen();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
        color: Colors.amber,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Foodies",style: TextStyle(fontSize: 45.sp,fontWeight: FontWeight.bold,color: Colors.black,letterSpacing: 1,fontFamily: 'Playwrite'),),
            Image.asset("assets/images/logo.png"),
            SizedBox(height: 8.h,),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> checkUser(context)));
              },
              child: Material(
                elevation: 7.0,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 80.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.amberAccent,
                  ),
                  child: Center(
                    child: Text(
                      "LOGIN AS USER",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp,color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h,),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AdminLogin()));
              },
              child: Material(
                elevation: 7.0,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 80.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.amberAccent,
                  ),
                  child: Center(
                    child: Text(
                      "LOGIN AS ADMIN",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp,color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
