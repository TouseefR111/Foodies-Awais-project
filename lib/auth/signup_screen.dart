import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app/views/my_bottom_nav.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:random_string/random_string.dart';
import 'package:sizer/sizer.dart';

import '../controller/database_methods.dart';
import '../controller/shared_pref_helper.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // VARIABLES
  // ============================================================

  String addId = randomAlphaNumeric(10);

  User? user = FirebaseAuth.instance.currentUser;

  bool obscureText = true;
  bool myObscureText = true;
  bool isLoading = false;

  // ============================================================
  // FORM KEY
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController contactController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  // ============================================================
  // LOADING SPINNER
  // ============================================================

  final spinkit = const SpinKitDancingSquare(color: Colors.white, size: 30.0);

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
        duration: const Duration(milliseconds: 2000),
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

    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
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
    // If animation controller hasn't been created yet,
    // simply show the widget.
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
  // REGISTER FUNCTION
  // ============================================================

  Future<void> registerData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      if (credential.user != null) {
        final uid = credential.user!.uid;

        Map<String, dynamic> userData = {
          "userId": uid,
          "userContact": contactController.text.trim(),
          "userName": nameController.text.trim(),
          "userEmail": emailController.text.trim(),
        };

        await DatabaseMethods().usersData(userData, uid);

        await SharedPrefHelper().saveUserId(uid);

        await SharedPrefHelper().saveUserName(nameController.text.trim());

        await SharedPrefHelper().saveUserContact(contactController.text.trim());

        await SharedPrefHelper().saveUserEmail(emailController.text.trim());

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Registration Successful",
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyBottomNav()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "The account already exists for this email.";
      } else {
        errorMessage = e.message ?? "An unexpected error occurred.";
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration buildDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

      contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade400,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              SizedBox(height: 2.h),

              // ==================================================
              // FOODIES LOGO
              // ==================================================
              animatedItem(
                start: 0.00,
                end: 0.20,

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
              // REGISTER CARD
              // ==================================================
              Material(
                elevation: 7,

                borderRadius: BorderRadius.circular(30),

                child: Container(
                  width: double.infinity,

                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 5.w),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      children: [
                        // ==================================================
                        // REGISTER TITLE
                        // ==================================================
                        animatedItem(
                          start: 0.10,
                          end: 0.30,

                          child: Text(
                            "Register Yourself",

                            textAlign: TextAlign.center,

                            style: GoogleFonts.poppins(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // ==================================================
                        // NAME
                        // ==================================================
                        animatedItem(
                          start: 0.20,
                          end: 0.40,

                          begin: const Offset(0.25, 0),

                          child: TextFormField(
                            controller: nameController,

                            decoration: buildDecoration(
                              hintText: "Name",
                              prefixIcon: Icons.person,
                            ),

                            textInputAction: TextInputAction.next,

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Required Name here";
                              }

                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // ==================================================
                        // CONTACT
                        // ==================================================
                        animatedItem(
                          start: 0.30,
                          end: 0.50,

                          begin: const Offset(-0.25, 0),

                          child: TextFormField(
                            controller: contactController,

                            decoration: buildDecoration(
                              hintText: "Contact",
                              prefixIcon: Icons.numbers,
                            ),

                            textInputAction: TextInputAction.next,

                            keyboardType: TextInputType.number,

                            maxLength: 11,

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Required Contact here";
                              }

                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // ==================================================
                        // EMAIL
                        // ==================================================
                        animatedItem(
                          start: 0.40,
                          end: 0.60,

                          begin: const Offset(0.25, 0),

                          child: TextFormField(
                            controller: emailController,

                            keyboardType: TextInputType.emailAddress,

                            decoration: buildDecoration(
                              hintText: "Email",
                              prefixIcon: Icons.email_outlined,
                            ),

                            textInputAction: TextInputAction.next,

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Required Email here";
                              }

                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: 2.h),

                        // ==================================================
                        // PASSWORD
                        // ==================================================
                        animatedItem(
                          start: 0.50,
                          end: 0.70,

                          begin: const Offset(-0.25, 0),

                          child: TextFormField(
                            controller: passwordController,

                            obscureText: myObscureText,

                            decoration: buildDecoration(
                              hintText: "Password",

                              prefixIcon: Icons.lock,

                              suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    myObscureText = !myObscureText;
                                  });
                                },

                                child: Icon(
                                  myObscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),

                            textInputAction: TextInputAction.done,

                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Required Password here";
                              }

                              return null;
                            },

                            onFieldSubmitted: (_) {
                              registerData();
                            },
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // ==================================================
                        // SIGN UP BUTTON
                        // ==================================================
                        animatedItem(
                          start: 0.65,
                          end: 0.82,

                          begin: const Offset(0, 0.3),

                          child: Container(
                            width: double.infinity,
                            height: 7.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),

                            child: ElevatedButton(
                              onPressed: isLoading ? null : registerData,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),

                              child: isLoading
                                  ? spinkit
                                  : Text(
                                      "Sign up",

                                      style: GoogleFonts.poppins(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // ==================================================
                        // LOGIN LINK
                        // ==================================================
                        animatedItem(
                          start: 0.78,
                          end: 1.00,

                          begin: const Offset(0, 0.2),

                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },

                            child: Text(
                              "Already have an Account?   Login",

                              textAlign: TextAlign.center,

                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                          ),
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
    );
  }
}
