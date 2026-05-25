import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app/admin/home_admin.dart';
import 'package:sizer/sizer.dart';

import '../auth/signup_screen.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  bool obscureText = true;
  TextEditingController idcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  bool isload = false;

  final spinkit = SpinKitChasingDots(
    color: Colors.white,
    size: 30.0,
  );

  getData() async {
    setState(() {
      isload = true;
    });

    await FirebaseFirestore.instance.collection("Admin").get().then((snapshot) {
      snapshot.docs.forEach((result) {
        if (result.data()["id"] != idcontroller.text.trim()) {
          setState(() {
            isload = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ID is not correct")),
          );
        } else if (result.data()["password"] != passwordcontroller.text.trim()) {
          setState(() {
            isload = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password is not correct")),
          );
        } else {
          setState(() {
            isload = false;
          });
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeAdmin()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevents resizing when the keyboard opens
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amberAccent,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      backgroundColor: Colors.amber,
      body: SafeArea(
        child: Center(
          child: Material(
            elevation: 7.0,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 80.w,
              height: 70.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 4.h),
                  Text(
                    "Admin Login".toUpperCase(),
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  SizedBox(height: 4.h),
                  // ID TextField
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Enter ID",
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      controller: idcontroller,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Password TextField
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: InkWell(
                          onTap: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          child: Icon(obscureText
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      controller: passwordcontroller,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  InkWell(
                    onTap: () {
                      getData();
                    },
                    child: Container(
                      width: 160,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.amberAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: isload
                            ? spinkit
                            : const Text(
                          "Log in",
                          style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
