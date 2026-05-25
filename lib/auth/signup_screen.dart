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


  final spinkit = const SpinKitDancingSquare(
    color: Colors.white,
    size: 30.0,
  );

  bool isLoading = false;
  bool myObscureText = true;

  Future<void> registerData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Register user in Firebase
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (credential.user != null) {
        // Save user data to database
        Map<String, dynamic> userData = {
          "userId": addId,
          "userContact":contactController.text.trim(),
          "userName": nameController.text.trim(),
          "userEmail": emailController.text.trim(),
        };

        await DatabaseMethods().usersData(userData, addId);
        // Save user data to shared preferences
        await SharedPrefHelper().saveUserId(addId);
        await SharedPrefHelper().saveUserName(nameController.text.trim());
        await SharedPrefHelper().saveUserContact(contactController.text.trim());
        await SharedPrefHelper().saveUserEmail(emailController.text.trim());

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
              content: Text("Registration Successful",style: TextStyle(color: Colors.white),)),
        );

        // Navigate to login screen
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      body: Container(
        child: Stack(
          children: [
            //title text
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "foodies".toUpperCase(),
                    style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.bold,color: Colors.black),
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
                mainAxisAlignment: MainAxisAlignment.center,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top:53.h,),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      },
                      child: Text(
                        "Already have an Account ?  Login",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                    ),
                  )
                ],
              ),
            ),

            Form(
              key: _formKey,
              child: Positioned(
                top: 160,
                left: 32,
                child: Material(
                  elevation: 7.0,
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          // color: Colors.redAccent,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: const Text(
                                "Register Yourself",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            //name field
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: "Name",
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                                textInputAction: TextInputAction.next,
                                controller: nameController,
                                validator: (value) => value!.isEmpty ? "Required Name here" : null,
                              ),
                            ),

                            SizedBox(
                              height: 3.h,
                            ),
                            //contact field
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: "Contact",
                                    prefixIcon: const Icon(Icons.numbers),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.number,
                                maxLength: 11,
                                controller: contactController,
                                validator: (value) => value!.isEmpty ? "Required Contact here" : null,
                              ),
                            ),

                            SizedBox(
                              height: 3.h,
                            ),
                            //Email field
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: "Email",
                                    prefixIcon: Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                                textInputAction: TextInputAction.next,
                                controller: emailController,
                                validator: (value) => value!.isEmpty ? "Required Email here" : null,
                              ),
                            ),
                            //password field
                            SizedBox(
                              height: 3.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: "Password",
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: InkWell(
                                        onTap: (){
                                          setState(() {
                                           myObscureText = !myObscureText;
                                          });
                                        },

                                        child: Icon(myObscureText ? Icons.visibility_off : Icons.visibility)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                                obscureText: myObscureText,
                                controller: passwordController,
                                validator: (value) => value!.isEmpty ?"Required Password here" : null,
                              ),
                            ),
                            SizedBox(
                              height: 4.h,
                            ),
                            InkWell(
                              onTap: (){
                               registerData();
                              },

                              child: Container(
                                width: 150,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.amberAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: isLoading ? spinkit :Text(
                                    "Sign up",
                                    style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4.h,
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
