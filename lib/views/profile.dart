import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';
import 'package:sizer/sizer.dart';

import '../controller/shared_pref_helper.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userId;
  String? userName;
  String? userContact;

  @override
  void initState() {
    super.initState();
    getShareId();
  }

  /// Fetch User ID from Shared Preferences
  Future<void> getShareId() async {
    userId = await SharedPrefHelper().getUserId();
    userName = await SharedPrefHelper().getUserName();
    userContact = await SharedPrefHelper().getUserContact();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 20.h,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(100, 50),
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(left: 140, top: 80),
                  width: 30.w,
                  height: 14.h,

                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage("assets/images/profile.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            //Name
            Material(
              elevation: 7.0,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 90.w,
                height: 8.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 4.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Name"),
                          Text(userName.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            //Email
            Material(
              elevation: 7.0,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 90.w,
                height: 8.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.email),
                      SizedBox(width: 4.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Email"), Text("".toString())],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            //Delete Account
            Material(
              elevation: 7.0,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 90.w,
                height: 8.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.book_outlined),
                      SizedBox(width: 4.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Terms & Conditions")],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            //Delete Account
            Material(
              elevation: 7.0,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 90.w,
                height: 8.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 4.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Delete Account")],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),
            //Delete Account
            Material(
              elevation: 7.0,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 90.w,
                height: 8.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.comment_outlined),
                      SizedBox(width: 4.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text("Complaints")],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),
            //Logout
            Material(
              elevation: 7.0,
              borderRadius: BorderRadius.circular(10),
              child: GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 90.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 4.w),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Text("Logout")],
                        ),
                      ],
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
