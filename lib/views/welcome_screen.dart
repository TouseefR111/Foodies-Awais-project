import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/admin/admin_login.dart';
import 'package:food_delivery_app/super%20admin/super_admin_login.dart';
import 'package:food_delivery_app/views/check_user.dart';
import 'package:sizer/sizer.dart';

import '../auth/login_screen.dart';
import '../views/my_bottom_nav.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;

  late AnimationController _animationController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<Offset> _logoSlide;

  late Animation<double> _userButtonFade;
  late Animation<Offset> _userButtonSlide;

  late Animation<double> _adminButtonFade;
  late Animation<Offset> _adminButtonSlide;

  late Animation<double> _superAdminButtonFade;
  late Animation<Offset> _superAdminButtonSlide;

  late Animation<double> _bottomFade;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // ============================================================
    // LOGO FADE
    // ============================================================

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    // ============================================================
    // LOGO SCALE
    // ============================================================

    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // ============================================================
    // LOGO SLIDE
    // ============================================================

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
          ),
        );

    // ============================================================
    // USER BUTTON
    // ============================================================

    _userButtonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.30, 0.58, curve: Curves.easeOut),
      ),
    );

    _userButtonSlide =
        Tween<Offset>(begin: const Offset(-0.25, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.30, 0.58, curve: Curves.easeOutCubic),
          ),
        );

    // ============================================================
    // ADMIN BUTTON
    // ============================================================

    _adminButtonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.45, 0.72, curve: Curves.easeOut),
      ),
    );

    _adminButtonSlide =
        Tween<Offset>(begin: const Offset(0.25, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.45, 0.72, curve: Curves.easeOutCubic),
          ),
        );

    // ============================================================
    // SUPER ADMIN BUTTON
    // ============================================================

    _superAdminButtonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.58, 0.84, curve: Curves.easeOut),
      ),
    );

    _superAdminButtonSlide =
        Tween<Offset>(begin: const Offset(-0.25, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.58, 0.84, curve: Curves.easeOutCubic),
          ),
        );

    // ============================================================
    // BOTTOM TEXT
    // ============================================================

    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.78, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation only AFTER every animation
    // has been initialized.
    _animationController.forward();
  }

  // ============================================================
  // CHECK USER
  // ============================================================

  Widget checkUser(BuildContext context) {
    return user != null ? const MyBottomNav() : const LoginScreen();
  }

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget loginButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onPressed,
    required Color iconBackground,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.amber.withOpacity(0.15),
        highlightColor: Colors.amber.withOpacity(0.08),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.7.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // ICON
              Container(
                width: 14.w,
                height: 14.w,
                constraints: const BoxConstraints(maxWidth: 58, maxHeight: 58),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.black87, size: 27),
              ),

              SizedBox(width: 4.w),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 0.4.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 1.w),

              // ARROW
              Container(
                width: 10.w,
                height: 10.w,
                constraints: const BoxConstraints(maxWidth: 42, maxHeight: 42),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ANIMATED BUTTON
  // ============================================================

  Widget animatedButton({
    required Animation<double> fadeAnimation,
    required Animation<Offset> slideAnimation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(position: slideAnimation, child: child),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.shade50,
                Colors.amber.shade200,
                Colors.amber.shade400,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 650),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==================================================
                    // FOODIES LOGO
                    // ==================================================
                    FadeTransition(
                      opacity: _logoFade,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Image.asset(
                            'assets/images/foodies_logo.png',
                            width: 68.w,
                            height: 13.h,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // ==================================================
                    // MAIN LOGO
                    // ==================================================
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 25,
                                spreadRadius: 2,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 55.w,
                              height: 55.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // ==================================================
                    // WELCOME TEXT
                    // ==================================================
                    FadeTransition(
                      opacity: _logoFade,
                      child: Column(
                        children: [
                          Text(
                            'Welcome to Foodies',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              letterSpacing: 0.3,
                            ),
                          ),

                          SizedBox(height: 0.8.h),

                          Text(
                            'Choose how you want to continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // ==================================================
                    // USER
                    // ==================================================
                    animatedButton(
                      fadeAnimation: _userButtonFade,
                      slideAnimation: _userButtonSlide,
                      child: loginButton(
                        title: 'Login as User',
                        subtitle: 'Order your favorite food',
                        icon: Icons.person_outline,
                        iconBackground: Colors.amber.shade200,
                        onPressed: () {
                          final Widget destination = checkUser(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => destination),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 1.8.h),

                    // ==================================================
                    // ADMIN
                    // ==================================================
                    animatedButton(
                      fadeAnimation: _adminButtonFade,
                      slideAnimation: _adminButtonSlide,
                      child: loginButton(
                        title: 'Login as Admin',
                        subtitle: 'Manage orders and products',
                        icon: Icons.admin_panel_settings_outlined,
                        iconBackground: Colors.blue.shade100,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AdminLogin(),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 1.8.h),

                    // ==================================================
                    // SUPER ADMIN
                    // ==================================================
                    animatedButton(
                      fadeAnimation: _superAdminButtonFade,
                      slideAnimation: _superAdminButtonSlide,
                      child: loginButton(
                        title: 'Login as Super Admin',
                        subtitle: 'Manage admins and permissions',
                        icon: Icons.security_outlined,
                        iconBackground: Colors.red.shade100,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SuperAdminLogin(),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // // ==================================================
                    // // BOTTOM TEXT
                    // // ==================================================
                    // FadeTransition(
                    //   opacity: _bottomFade,
                    //   child: Text(
                    //     'Delicious food. Simple ordering.',
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       fontSize: 14.sp,
                    //       color: Colors.black45,
                    //       fontStyle: FontStyle.italic,
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
