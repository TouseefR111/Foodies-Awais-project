import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/views/cart_screen.dart';
import 'package:food_delivery_app/views/home_screen.dart';
import 'package:food_delivery_app/views/my_order.dart';
import 'package:food_delivery_app/views/profile.dart';

class MyBottomNav extends StatefulWidget {
  const MyBottomNav({super.key});

  @override
  State<MyBottomNav> createState() => _MyBottomNavState();
}

class _MyBottomNavState extends State<MyBottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;

  late HomeScreen homeScreen;
  late CartScreen cartScreen;
  late MyOrder myOrder;
  late Profile profile;

  @override
  void initState() {
    super.initState();

    homeScreen = const HomeScreen();
    cartScreen = const CartScreen();
    myOrder = const MyOrder();
    profile = const Profile();

    pages = [homeScreen, cartScreen, myOrder, profile];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      // ==========================================================
      // BODY
      // ==========================================================
      body: pages[currentTabIndex],

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 14, right: 14, bottom: 10),

        height: 65,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),

          gradient: const LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),

        // IMPORTANT:
        // Prevent the selected button from visually
        // escaping the navigation container.
        clipBehavior: Clip.hardEdge,

        child: CurvedNavigationBar(
          index: currentTabIndex,

          // Transparent so our gradient remains visible
          color: Colors.transparent,

          backgroundColor: Colors.transparent,

          // Smaller navigation height
          height: 60,

          // White selected button
          buttonBackgroundColor: Colors.white,

          animationDuration: const Duration(milliseconds: 300),

          animationCurve: Curves.easeInOut,

          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },

          items: [
            _buildNavIcon(Icons.home_rounded, 0),

            _buildNavIcon(Icons.shopping_cart_rounded, 1),

            _buildNavIcon(Icons.receipt_long_rounded, 2),

            _buildNavIcon(Icons.person_rounded, 3),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION ICON
  // ============================================================

  Widget _buildNavIcon(IconData icon, int index) {
    final bool isSelected = currentTabIndex == index;

    return Icon(
      icon,
      size: isSelected ? 23 : 23,
      color: isSelected ? const Color(0xFFFF9800) : Colors.black87,
    );
  }
}
