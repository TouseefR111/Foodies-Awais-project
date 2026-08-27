import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app/admin/home_admin.dart';
import 'package:sizer/sizer.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _formKey = GlobalKey<FormState>();
  bool obscureText = true;
  final TextEditingController idcontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();

  bool isload = false;

  final spinkit = const SpinKitChasingDots(color: Colors.white, size: 30.0);

  Future<void> getData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isload = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('id', isEqualTo: idcontroller.text.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("ID is not correct")));
        setState(() => isload = false);
        return;
      }

      final data = snapshot.docs.first.data();
      final storedPassword = data['password'] ?? '';

      if (storedPassword != passwordcontroller.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password is not correct")),
        );
        setState(() => isload = false);
        return;
      }

      // Success
      setState(() => isload = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeAdmin()),
      );
    } catch (e) {
      setState(() => isload = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    }
  }

  @override
  void dispose() {
    idcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Material(
                elevation: 8.0,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "ADMIN LOGIN",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        TextFormField(
                          controller: idcontroller,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: "Enter ID",
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 1.8.h,
                              horizontal: 3.w,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Please enter ID"
                              : null,
                        ),
                        SizedBox(height: 2.h),
                        TextFormField(
                          controller: passwordcontroller,
                          obscureText: obscureText,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: InkWell(
                              onTap: () =>
                                  setState(() => obscureText = !obscureText),
                              child: Icon(
                                obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 1.8.h,
                              horizontal: 3.w,
                            ),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? "Please enter password"
                              : null,
                        ),
                        SizedBox(height: 3.h),
                        SizedBox(
                          width: double.infinity,
                          height: 7.h,
                          child: ElevatedButton(
                            onPressed: isload ? null : getData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amberAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isload
                                ? spinkit
                                : Text(
                                    "Log in",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
