import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/views/my_bottom_nav.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';
import 'package:sizer/sizer.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Main logo animations
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<Offset> _logoSlide;

  // Foodies logo animations
  late Animation<double> _foodiesFade;
  late Animation<double> _foodiesScale;
  late Animation<Offset> _foodiesSlide;

  // Ring animation
  late Animation<double> _ringRotation;
  late Animation<double> _ringScale;

  // Particles
  late Animation<double> _particleFade;

  // Bottom content
  late Animation<double> _bottomFade;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // ==================================================
    // ANIMATION CONTROLLER
    // ==================================================

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // ==================================================
    // MAIN LOGO FADE
    // ==================================================

    _logoFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    // ==================================================
    // MAIN LOGO SCALE
    // ==================================================

    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    // ==================================================
    // MAIN LOGO SLIDE
    // ==================================================

    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
          ),
        );

    // ==================================================
    // FOODIES LOGO FADE
    // ==================================================

    _foodiesFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
    );

    // ==================================================
    // FOODIES LOGO SCALE
    // ==================================================

    _foodiesScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutBack),
      ),
    );

    // ==================================================
    // FOODIES LOGO SLIDE
    // ==================================================

    _foodiesSlide =
        Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.25, 0.70, curve: Curves.easeOutCubic),
          ),
        );

    // ==================================================
    // ROTATING RING
    // ==================================================

    _ringRotation = Tween<double>(begin: 0, end: math.pi * 2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // ==================================================
    // RING SCALE
    // ==================================================

    _ringScale = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // ==================================================
    // PARTICLE FADE
    // ==================================================

    _particleFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.10, 0.70, curve: Curves.easeIn),
    );

    // ==================================================
    // BOTTOM CONTENT FADE
    // ==================================================

    _bottomFade = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );

    // Start animation
    _animationController.forward();

    // ==================================================
    // 8 SECOND SPLASH
    // ==================================================

    _timer = Timer(const Duration(seconds: 8), _checkAuthentication);
  }

  // ==================================================
  // CHECK AUTHENTICATION
  // ==================================================

  void _checkAuthentication() {
    if (!mounted) return;

    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, animation, secondaryAnimation) {
            return const MyBottomNav();
          },
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, animation, secondaryAnimation) {
            return const WelcomeScreen();
          },
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
        ),
      );
    }
  }

  // ==================================================
  // DISPOSE
  // ==================================================

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // ==================================================
        // AMBER / ORANGE GRADIENT
        // ==================================================
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade50,
              Colors.amber.shade200,
              Colors.amber.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Stack(
          alignment: Alignment.center,
          children: [
            // ==================================================
            // TOP DECORATIVE CIRCLE
            // ==================================================
            Positioned(
              top: -90,
              left: -80,
              child: Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // ==================================================
            // BOTTOM DECORATIVE CIRCLE
            // ==================================================
            Positioned(
              bottom: -100,
              right: -90,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),

            // ==================================================
            // DECORATIVE PARTICLES
            // ==================================================
            FadeTransition(
              opacity: _particleFade,
              child: Stack(
                children: [
                  Positioned(top: 17.h, left: 12.w, child: _particle(7)),

                  Positioned(top: 25.h, right: 13.w, child: _particle(5)),

                  Positioned(top: 63.h, left: 10.w, child: _particle(5)),

                  Positioned(bottom: 20.h, right: 12.w, child: _particle(7)),

                  Positioned(top: 40.h, left: 7.w, child: _particle(3)),

                  Positioned(top: 48.h, right: 8.w, child: _particle(4)),
                ],
              ),
            ),

            // ==================================================
            // ROTATING DECORATIVE RING
            // ==================================================
            ScaleTransition(
              scale: _ringScale,
              child: AnimatedBuilder(
                animation: _ringRotation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _ringRotation.value,
                    child: child,
                  );
                },
                child: SizedBox(
                  width: 82.w,
                  height: 82.w,
                  child: Stack(
                    children: [
                      // Top
                      Positioned(top: 0, left: 41.w - 4, child: _ringDot(8)),

                      // Bottom
                      Positioned(bottom: 0, left: 41.w - 3, child: _ringDot(6)),

                      // Left
                      Positioned(left: 0, top: 41.w - 3, child: _ringDot(6)),

                      // Right
                      Positioned(right: 0, top: 41.w - 4, child: _ringDot(8)),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // CENTER CONTENT
            // ==================================================
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ==================================================
                // MAIN LOGO
                // ==================================================
                FadeTransition(
                  opacity: _logoFade,
                  child: SlideTransition(
                    position: _logoSlide,
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
                ),

                SizedBox(height: 2.5.h),

                // ==================================================
                // FOODIES LOGO
                // ==================================================
                FadeTransition(
                  opacity: _foodiesFade,
                  child: SlideTransition(
                    position: _foodiesSlide,
                    child: ScaleTransition(
                      scale: _foodiesScale,
                      child: Image.asset(
                        'assets/images/foodies_logo.png',
                        width: 68.w,
                        height: 13.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // ==================================================
                // TAGLINE
                // ==================================================
                FadeTransition(
                  opacity: _bottomFade,
                  child: Text(
                    "GOOD FOOD. GOOD MOOD.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.2,
                      color: Colors.black.withOpacity(0.70),
                    ),
                  ),
                ),

                SizedBox(height: 2.5.h),

                // ==================================================
                // LOADING BAR
                // ==================================================
                FadeTransition(
                  opacity: _bottomFade,
                  child: SizedBox(
                    width: 45.w,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        minHeight: 0.7.h,
                        backgroundColor: Colors.white.withOpacity(0.30),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 1.8.h),

                // ==================================================
                // LOADING TEXT
                // ==================================================
                FadeTransition(
                  opacity: _bottomFade,
                  child: Text(
                    "Preparing your experience...",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.65),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // PARTICLE
  // ==================================================

  Widget _particle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.65),
        boxShadow: [
          BoxShadow(color: Colors.white.withOpacity(0.25), blurRadius: 8),
        ],
      ),
    );
  }

  // ==================================================
  // RING DOT
  // ==================================================

  Widget _ringDot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.70),
      ),
    );
  }
}
