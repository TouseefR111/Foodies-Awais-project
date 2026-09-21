import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'super_admin_screen.dart';

class SuperAdminLogin extends StatefulWidget {
  const SuperAdminLogin({super.key});

  @override
  State<SuperAdminLogin> createState() => _SuperAdminLoginState();
}

class _SuperAdminLoginState extends State<SuperAdminLogin>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController animationController;

  bool isLoad = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    animationController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // ANIMATION
  // ----------------------------------------------------------

  Widget animatedItem({
    required Widget child,
    required double start,
    required double end,
  }) {
    final animation = CurvedAnimation(
      parent: animationController,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  // ----------------------------------------------------------
  // SUPER ADMIN LOGIN
  // ----------------------------------------------------------

  Future<void> loginSuperAdmin() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      showMessage("Please enter your email address.");
      return;
    }

    if (password.isEmpty) {
      showMessage("Please enter your password.");
      return;
    }

    setState(() {
      isLoad = true;
    });

    try {
      // ------------------------------------------------------
      // STEP 1: FIREBASE AUTHENTICATION
      // ------------------------------------------------------

      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception("Unable to get authenticated user.");
      }

      // ------------------------------------------------------
      // STEP 2: GET FIREBASE AUTH UID
      // ------------------------------------------------------

      final String uid = user.uid;

      // ------------------------------------------------------
      // STEP 3: GET SUPER ADMIN DOCUMENT
      //
      // Collection:
      // SuperAdmin
      //
      // Document ID:
      // Firebase Authentication UID
      // ------------------------------------------------------

      final DocumentSnapshot<Map<String, dynamic>> document = await _firestore
          .collection('SuperAdmin')
          .doc(uid)
          .get();

      // ------------------------------------------------------
      // STEP 4: CHECK DOCUMENT EXISTS
      // ------------------------------------------------------

      if (!document.exists) {
        await _auth.signOut();

        if (mounted) {
          setState(() {
            isLoad = false;
          });
        }

        showMessage(
          "You are authenticated, but you are not registered as a Super Admin.",
        );

        return;
      }

      final Map<String, dynamic> data = document.data() ?? {};

      // ------------------------------------------------------
      // STEP 5: CHECK ROLE
      // ------------------------------------------------------

      final String role = data['role']?.toString() ?? '';

      if (role != 'superAdmin') {
        await _auth.signOut();

        if (mounted) {
          setState(() {
            isLoad = false;
          });
        }

        showMessage("This account does not have Super Admin access.");

        return;
      }

      // ------------------------------------------------------
      // STEP 6: CHECK ACTIVE STATUS
      // ------------------------------------------------------

      final bool active = data['active'] == true;

      if (!active) {
        await _auth.signOut();

        if (mounted) {
          setState(() {
            isLoad = false;
          });
        }

        showMessage("Your Super Admin account is currently inactive.");

        return;
      }

      // ------------------------------------------------------
      // LOGIN SUCCESSFUL
      // ------------------------------------------------------

      if (!mounted) return;

      setState(() {
        isLoad = false;
      });

      // Stop login screen animation
      animationController.stop();

      // Small delay prevents keyboard/layout transition issues
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      // ------------------------------------------------------
      // GO TO SUPER ADMIN DASHBOARD
      // ------------------------------------------------------

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SuperAdminScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          isLoad = false;
        });
      }

      String message = "Login failed.";

      switch (e.code) {
        case 'invalid-credential':
          message = "Incorrect email or password.";
          break;

        case 'invalid-email':
          message = "Please enter a valid email address.";
          break;

        case 'user-disabled':
          message = "This account has been disabled.";
          break;

        case 'user-not-found':
          message = "No account exists with this email.";
          break;

        case 'wrong-password':
          message = "Incorrect password.";
          break;

        case 'too-many-requests':
          message = "Too many login attempts. Please try again later.";
          break;

        case 'network-request-failed':
          message = "Network error. Please check your internet connection.";
          break;

        default:
          message = e.message ?? "Unable to login.";
      }

      showMessage(message);
    } on FirebaseException catch (e) {
      if (mounted) {
        setState(() {
          isLoad = false;
        });
      }

      showMessage("Firebase error: ${e.message ?? 'Something went wrong.'}");
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoad = false;
        });
      }

      showMessage("Something went wrong. Please try again.");
    }
  }

  // ----------------------------------------------------------
  // MESSAGE
  // ----------------------------------------------------------

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFECB04),

      body: SafeArea(
        child: Stack(
          children: [
            // ==================================================
            // BACKGROUND
            // ==================================================
            Positioned(
              top: -8.h,
              right: -15.w,
              child: Container(
                width: 55.w,
                height: 55.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            Positioned(
              bottom: -10.h,
              left: -20.w,
              child: Container(
                width: 65.w,
                height: 65.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ==================================================
                      // FOODIES LOGO
                      // ==================================================
                      animatedItem(
                        start: 0.0,
                        end: 0.35,
                        child: Image.asset(
                          'assets/images/foodies_logo.png',
                          height: 13.h,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              "FOODIES",
                              style: GoogleFonts.poppins(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // ==================================================
                      // SUPER ADMIN TITLE
                      // ==================================================
                      animatedItem(
                        start: 0.15,
                        end: 0.45,
                        child: Text(
                          "Super Admin",
                          style: GoogleFonts.poppins(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      SizedBox(height: 0.5.h),

                      animatedItem(
                        start: 0.20,
                        end: 0.50,
                        child: Text(
                          "Sign in to manage Foodies",
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // ==================================================
                      // LOGIN CARD
                      // ==================================================
                      animatedItem(
                        start: 0.30,
                        end: 0.75,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // ==================================================
                              // EMAIL
                              // ==================================================
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Email",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              SizedBox(height: 0.8.h),

                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autocorrect: false,
                                decoration: InputDecoration(
                                  hintText: "Enter Super Admin email",
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Colors.black54,
                                    size: 23,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFFC107),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 2.h),

                              // ==================================================
                              // PASSWORD
                              // ==================================================
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Password",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),

                              SizedBox(height: 0.8.h),

                              TextField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) {
                                  if (!isLoad) {
                                    loginSuperAdmin();
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "Enter password",
                                  hintStyle: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.grey,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Colors.black54,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFFFC107),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 3.h),

                              // ==================================================
                              // LOGIN BUTTON
                              // ==================================================
                              Container(
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
                                  onPressed: isLoad ? null : loginSuperAdmin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: isLoad
                                      ? const SpinKitThreeBounce(
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : Text(
                                          "LOGIN",
                                          style: GoogleFonts.poppins(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Text(
                            "Not an admin? ",

                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: Colors.black87,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (context) => const WelcomeScreen(),
                                ),
                              );
                            },

                            child: Text(
                              "Go back to Navigation Screen",

                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 1.h),

                      // ==================================================
                      // BOTTOM IMAGE
                      // ==================================================
                      animatedItem(
                        start: 0.55,
                        end: 1.0,
                        child: Image.asset(
                          'assets/images/login.png',
                          // height: 20.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox.shrink();
                          },
                        ),
                      ),

                      SizedBox(height: 1.h),

                      // animatedItem(
                      //   start: 0.70,
                      //   end: 1.0,
                      //   child: Text(
                      //     "Foodies • Super Admin Portal",
                      //     style: GoogleFonts.poppins(
                      //       fontSize: 14.sp,
                      //       color: Colors.black54,
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // LOADING OVERLAY
            // ==================================================
            if (isLoad)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(color: Colors.black.withOpacity(0.08)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
