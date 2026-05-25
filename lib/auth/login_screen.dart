import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app/auth/signup_screen.dart';
import 'package:sizer/sizer.dart';

import '../controller/database_methods.dart';
import '../controller/shared_pref_helper.dart';
import '../views/home_screen.dart';
import '../views/my_bottom_nav.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  String? userId;
  // Added for loading state

  @override
  void initState() {
    super.initState();
    getShareId();
  }

  /// Fetch User ID from Shared Preferences
  Future<void> getShareId() async {
    userId = await SharedPrefHelper().getUserId();
    setState(() {});
  }

  bool obscureText = true;
  final spinkit = const SpinKitChasingDots(
    color: Colors.white,
    size: 30.0,
  );

  bool isLoad = false;

  loginData() async {
    setState(() {
      isLoad = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (credential.user != null) {
        // String userId = credential.user!.uid;  // Get user ID

        // Fetch user data from Firestore
        var userDoc = await DatabaseMethods().getUserData(userId.toString());

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

          // Save retrieved data in SharedPreferences
          await SharedPrefHelper().saveUserId(userId.toString());
          await SharedPrefHelper().saveUserName(userData["userName"]);
          await SharedPrefHelper().saveUserContact(userData["userContact"]);
          await SharedPrefHelper().saveUserEmail(userData["userEmail"]);

          setState(() {
            isLoad = false;
          });

          // Navigate to the main screen
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const MyBottomNav()));
        } else {
          setState(() {
            isLoad = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User data not found in Firestore")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoad = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.code.toString())),
      );
    }
  }



  @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.amber,
        body: Container(
          child: Stack(
            children: [
              //title text
              Padding(
                padding: EdgeInsets.symmetric(vertical:5.h),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "FOODIES",
                        style:
                        TextStyle(fontSize: 40, fontWeight: FontWeight.bold,color: Colors.black,letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),
              // //end container
              Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
                height: 600,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 11.h, left: 16.w),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>
                                  const SignupScreen()));
                        },
                        child: Text(
                          "Does not have an Account? Sign up",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Form(
                key: formKey,
                child: Positioned(
                  top: 160,
                  left: 38,
                  child: Material(
                    elevation: 7.0,
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        Container(
                          width: 80.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            // color: Colors.redAccent,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  "Log In Here",
                                  style: TextStyle(
                                      fontSize: 20.sp, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              //Email field
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      hintText: "Email",
                                      prefixIcon: const Icon(Icons.email_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                  textInputAction: TextInputAction.next,
                                  controller: emailController,
                                  validator: (value) => value!.isEmpty ?"Required Email here" : null,
                                ),
                              ),
                              //password field
                              SizedBox(
                                height: 5.h,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: TextFormField(
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
                                              : Icons.visibility)),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )),
                                  textInputAction: TextInputAction.next,
                                  controller: passwordController,
                                  validator: (value) => value!.isEmpty ? "Required password here" : null,
                                  obscureText: obscureText,
                                ),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              InkWell(
                                onTap: () {
                                  if (formKey.currentState!.validate()) {
                                    loginData();
                                  }
                                },
                                child: Container(
                                  width: 160,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: isLoad ? spinkit : Text(
                                      "Log in",
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                            ],
                          ),
                        ),
                      ],
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

