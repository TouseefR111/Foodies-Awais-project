import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_delivery_app/admin/home_admin.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:food_delivery_app/admin/admin_chat.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // FORM
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  final TextEditingController idcontroller = TextEditingController();

  final TextEditingController passwordcontroller = TextEditingController();

  bool obscureText = true;
  bool isload = false;

  final spinkit = const SpinKitChasingDots(color: Colors.white, size: 30.0);

  // ============================================================
  // ANIMATION
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

    idcontroller.dispose();
    passwordcontroller.dispose();

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

  Future<void> _showDeactivatedDialog({
    required String reason,
    required Timestamp? deactivatedAt,
    required String adminDocumentId,
    required String adminName,
    required String adminId,
  }) async {
    if (!mounted) return;

    String dateText = '';

    if (deactivatedAt != null) {
      final date = deactivatedAt.toDate();

      dateText =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(Icons.block, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Account Deactivated',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your admin account has been deactivated by the Super Admin.',
                  style: TextStyle(fontSize: 15, height: 1.4),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Reason:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),

                const SizedBox(height: 7),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    reason.isNotEmpty ? reason : 'No reason was provided.',
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),

                if (dateText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Deactivated on: $dateText',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],

                const SizedBox(height: 18),

                const Text(
                  'If you believe your account should be reactivated, '
                  'you can contact the Super Admin.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AdminChat(
                      adminDocumentId: adminDocumentId,
                      adminName: adminName,
                      adminId: adminId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat, color: Colors.black),
              label: const Text(
                'Contact Super Admin',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ADMIN LOGIN
  // ============================================================

  Future<void> getData() async {
    // Close keyboard
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isload = true;
    });

    try {
      // ========================================================
      // FIND ADMIN BY ID
      // ========================================================

      final snapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('id', isEqualTo: idcontroller.text.trim())
          .limit(1)
          .get();

      // ========================================================
      // CHECK ID
      // ========================================================

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;

        setState(() {
          isload = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("ID is not correct")));

        return;
      }

      // ========================================================
      // GET EXACT ADMIN DOCUMENT
      // ========================================================

      final adminDocument = snapshot.docs.first;

      final Map<String, dynamic> data = adminDocument.data();

      // This is the exact Firestore document ID.
      final String adminDocumentId = adminDocument.id;

      // ========================================================
      // DEBUG INFORMATION
      // ========================================================

      debugPrint('======================================');

      debugPrint('ADMIN LOGIN');

      debugPrint('Admin Document ID: $adminDocumentId');

      debugPrint('Admin ID: ${data['id']}');

      debugPrint('Admin Name: ${data['name']}');

      debugPrint('Admin Email: ${data['email']}');

      debugPrint('Active: ${data['active']}');

      debugPrint('canManageOrders: ${data['canManageOrders']}');

      debugPrint('canManageProducts: ${data['canManageProducts']}');

      debugPrint('canManageUsers: ${data['canManageUsers']}');

      debugPrint('canViewComplaints: ${data['canViewComplaints']}');

      debugPrint('======================================');

      // ========================================================
      // CHECK ACTIVE
      // ========================================================

      final bool active = data['active'] ?? true;

      if (!active) {
        if (!mounted) return;

        setState(() {
          isload = false;
        });

        final String deactivationReason =
            data['deactivationReason']?.toString().trim() ?? '';

        final Timestamp? deactivatedAt = data['deactivatedAt'] is Timestamp
            ? data['deactivatedAt'] as Timestamp
            : null;

        final String adminName = data['name']?.toString() ?? 'Admin';

        final String adminId = data['id']?.toString() ?? '';

        await _showDeactivatedDialog(
          reason: deactivationReason,
          deactivatedAt: deactivatedAt,
          adminDocumentId: adminDocumentId,
          adminName: adminName,
          adminId: adminId,
        );

        return;
      }

      // ========================================================
      // GET PASSWORD
      // ========================================================

      final String storedPassword = data['password']?.toString() ?? '';

      // ========================================================
      // CHECK PASSWORD
      // ========================================================

      if (storedPassword != passwordcontroller.text.trim()) {
        if (!mounted) return;

        setState(() {
          isload = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password is not correct")),
        );

        return;
      }

      // ========================================================
      // LOGIN SUCCESS
      // ========================================================

      if (!mounted) return;

      // Stop animation
      _animationController?.stop();

      setState(() {
        isload = false;
      });

      // Close keyboard
      FocusManager.instance.primaryFocus?.unfocus();

      // Allow layout to settle
      await Future.delayed(const Duration(milliseconds: 150));

      if (!mounted) return;

      // ========================================================
      // OPEN ADMIN DASHBOARD
      //
      // PASS:
      // 1. EXACT ADMIN DOCUMENT ID
      // 2. COMPLETE ADMIN DATA
      // ========================================================

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              HomeAdmin(adminDocumentId: adminDocumentId, adminData: data),

          transitionDuration: Duration.zero,

          reverseTransitionDuration: Duration.zero,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isload = false;
      });

      debugPrint('Admin Login Error: $e');

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
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

      backgroundColor: Color(0xFFFECB04),

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
                        key: _formKey,

                        child: Column(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            // ==================================================
                            // TITLE
                            // ==================================================
                            animatedItem(
                              start: 0.15,
                              end: 0.35,

                              child: Text(
                                "ADMIN LOGIN",

                                style: GoogleFonts.poppins(
                                  fontSize: 20.sp,

                                  fontWeight: FontWeight.w700,

                                  color: Colors.black,
                                ),
                              ),
                            ),

                            SizedBox(height: 2.h),

                            // ==================================================
                            // ID FIELD
                            // ==================================================
                            animatedItem(
                              start: 0.25,
                              end: 0.45,

                              begin: const Offset(0.25, 0),

                              child: TextFormField(
                                controller: idcontroller,

                                textInputAction: TextInputAction.next,

                                decoration: _inputDecoration(
                                  hint: "Enter ID",

                                  icon: Icons.person_outline,
                                ),

                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return "Please enter ID";
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
                                controller: passwordcontroller,

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
                                    return "Please enter password";
                                  }

                                  return null;
                                },

                                onFieldSubmitted: (_) {
                                  if (!isload) {
                                    getData();
                                  }
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
                                  onPressed: isload ? null : getData,

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),

                                  child: isload
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
                          ],
                        ),
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
