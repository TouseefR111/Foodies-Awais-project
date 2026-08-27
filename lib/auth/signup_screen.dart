import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app/views/my_bottom_nav.dart';
import 'package:random_string/random_string.dart';
import 'package:sizer/sizer.dart';

import '../controller/database_methods.dart';
import '../controller/shared_pref_helper.dart';
import '../views/home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String addId = randomAlphaNumeric(10);
  User? user = FirebaseAuth.instance.currentUser;
  bool obscureText = true;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final spinkit = const SpinKitDancingSquare(color: Colors.white, size: 30.0);

  bool isLoading = false;
  bool myObscureText = true;

  Future<void> registerData() async {
    if (!_formKey.currentState!.validate()) return;

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
              Text(
                "FOODIES",
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 3.h),
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
                        Text(
                          "Register Yourself",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        TextFormField(
                          controller: nameController,
                          decoration: buildDecoration(
                            hintText: "Name",
                            prefixIcon: Icons.person,
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value!.isEmpty ? "Required Name here" : null,
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
                          controller: contactController,
                          decoration: buildDecoration(
                            hintText: "Contact",
                            prefixIcon: Icons.numbers,
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          maxLength: 11,
                          validator: (value) =>
                              value!.isEmpty ? "Required Contact here" : null,
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
                          controller: emailController,
                          decoration: buildDecoration(
                            hintText: "Email",
                            prefixIcon: Icons.email_outlined,
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) =>
                              value!.isEmpty ? "Required Email here" : null,
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
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
                          validator: (value) =>
                              value!.isEmpty ? "Required Password here" : null,
                        ),
                        SizedBox(height: 4.h),
                        SizedBox(
                          width: double.infinity,
                          height: 7.h,
                          child: ElevatedButton(
                            onPressed: registerData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amberAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: isLoading
                                ? spinkit
                                : Text(
                                    "Sign up",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Already have an Account? Login",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
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
      ),
    );
  }
}
