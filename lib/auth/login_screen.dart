import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app/auth/signup_screen.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../controller/database_methods.dart';
import '../controller/shared_pref_helper.dart';
import '../views/my_bottom_nav.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // FORM CONTROLLERS
  // ============================================================

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscureText = true;
  bool isLoad = false;

  final spinkit = const SpinKitChasingDots(color: Colors.white, size: 30.0);

  // ============================================================
  // ANIMATION CONTROLLER
  // ============================================================

  AnimationController? _animationController;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      );

      setState(() {});

      _animationController!.forward();
    });
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController?.dispose();

    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // ANIMATION WIDGET
  // ============================================================

  Widget animatedItem({
    required Widget child,
    required double start,
    required double end,
    Offset begin = const Offset(0, 0.2),
  }) {
    // Before controller is created, simply show the widget.
    if (_animationController == null) {
      return child;
    }

    final Animation<double> animation = CurvedAnimation(
      parent: _animationController!,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  // ============================================================
  // LOGIN FUNCTION
  // ============================================================

  // Future<void> getData() async {
  //   // Close keyboard
  //   FocusScope.of(context).unfocus();

  Future<void> loginData() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoad = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user?.uid;

      if (uid == null) {
        throw Exception('Login failed');
      }

      final userDoc = await DatabaseMethods().getUserData(uid);

      if (!userDoc.exists) {
        if (!mounted) return;

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
      if (mounted) {
        setState(() {
          isLoad = false;
        });
      }
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.amber.shade400,
      appBar: AppBar(
        toolbarHeight: 30,
        backgroundColor: Colors.amber.shade400,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );
          },
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 2.h),

                  // ==================================================
                  // FOODIES LOGO
                  // ==================================================
                  animatedItem(
                    start: 0.00,
                    end: 0.25,
                    begin: const Offset(0, -0.25),

                    child: Center(
                      child: Image.asset(
                        'assets/images/foodies_logo.png',
                        width: 70.w,
                        height: 14.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // ==================================================
                  // LOGIN CARD
                  // ==================================================
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
                            // ==================================================
                            // LOGIN TITLE
                            // ==================================================
                            animatedItem(
                              start: 0.15,
                              end: 0.35,

                              child: Text(
                                "Log In",

                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // ==================================================
                            // EMAIL FIELD
                            // ==================================================
                            animatedItem(
                              start: 0.25,
                              end: 0.45,
                              begin: const Offset(0.25, 0),

                              child: TextFormField(
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

                                  if (!emailRegex.hasMatch(email)) {
                                    return "Enter a valid email";
                                  }

                                  return null;
                                },
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // ==================================================
                            // PASSWORD FIELD
                            // ==================================================
                            animatedItem(
                              start: 0.35,
                              end: 0.55,
                              begin: const Offset(-0.25, 0),

                              child: TextFormField(
                                controller: passwordController,

                                obscureText: obscureText,

                                textInputAction: TextInputAction.done,

                                decoration: _inputDecoration(
                                  hint: "Password",
                                  icon: Icons.lock_outline,

                                  suffix: InkWell(
                                    onTap: () {
                                      setState(() {
                                        obscureText = !obscureText;
                                      });
                                    },

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

                                onFieldSubmitted: (_) {
                                  loginData();
                                },
                              ),
                            ),

                            SizedBox(height: 3.h),

                            // ==================================================
                            // LOGIN BUTTON
                            // ==================================================
                            animatedItem(
                              start: 0.50,
                              end: 0.70,

                              child: Container(
                                width: double.infinity,
                                height: 7.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFD54F),
                                      Color(0xFFFFA000),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),

                                child: ElevatedButton(
                                  onPressed: isLoad ? null : loginData,

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),

                                  child: isLoad
                                      ? spinkit
                                      : Text(
                                          "Log in",

                                          style: GoogleFonts.poppins(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                ),
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // ==================================================
                            // SIGN UP
                            // ==================================================
                            animatedItem(
                              start: 0.65,
                              end: 0.85,

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  Text(
                                    "Don't have an account? ",

                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      color: Colors.black87,
                                    ),
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

                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // ==================================================
                  // FOOD IMAGE
                  // ==================================================
                  animatedItem(
                    start: 0.75,
                    end: 1.00,
                    begin: const Offset(0, 0.25),

                    child: SizedBox(
                      width: double.infinity,
                      height: 28.h,

                      child: Image.asset(
                        'assets/images/login.png',
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
