import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app/auth/signup_screen.dart';
import 'package:sizer/sizer.dart';

import '../controller/database_methods.dart';
import '../controller/shared_pref_helper.dart';
import '../views/my_bottom_nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscureText = true;
  bool isLoad = false;
  final spinkit = const SpinKitChasingDots(color: Colors.white, size: 30.0);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginData() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoad = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user?.uid;
      if (uid == null) throw Exception('Login failed');

      final userDoc = await DatabaseMethods().getUserData(uid);

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data not found in Firestore")),
        );
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      await SharedPrefHelper().saveUserId(uid);
      await SharedPrefHelper().saveUserName(userData["userName"] ?? "");
      await SharedPrefHelper().saveUserContact(userData["userContact"] ?? "");
      await SharedPrefHelper().saveUserEmail(userData["userEmail"] ?? "");

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyBottomNav()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    } finally {
      if (mounted) setState(() => isLoad = false);
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade400,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 2.h),
                  Center(
                    child: Text(
                      "FOODIES",
                      style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 3.h,
                        horizontal: 5.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(
                                hint: "Email",
                                icon: Icons.email_outlined,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return "Email is required";
                                }
                                final email = v.trim();
                                final emailRegex = RegExp(
                                  r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                                );
                                return emailRegex.hasMatch(email)
                                    ? null
                                    : "Enter a valid email";
                              },
                            ),
                            SizedBox(height: 2.h),
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscureText,
                              textInputAction: TextInputAction.done,
                              decoration: _inputDecoration(
                                hint: "Password",
                                icon: Icons.lock_outline,
                                suffix: InkWell(
                                  onTap: () => setState(
                                    () => obscureText = !obscureText,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(0.8.w),
                                    child: Icon(
                                      obscureText
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return "Password is required";
                                }
                                if (v.trim().length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => loginData(),
                            ),
                            SizedBox(height: 3.h),
                            SizedBox(
                              width: double.infinity,
                              height: 7.h,
                              child: ElevatedButton(
                                onPressed: isLoad ? null : loginData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amberAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: isLoad
                                    ? spinkit
                                    : Text(
                                        "Log in",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Sign up",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
