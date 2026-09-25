import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/views/cart_screen.dart';
import 'package:food_delivery_app/views/complaints_screen.dart';
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
  late ComplaintsScreen complaintsScreen;
  late Profile profile;

  @override
  void initState() {
    super.initState();

    homeScreen = const HomeScreen();
    cartScreen = const CartScreen();
    myOrder = const MyOrder();
    complaintsScreen = const ComplaintsScreen();
    profile = const Profile();

    pages = [homeScreen, cartScreen, myOrder, complaintsScreen, profile];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentTabIndex, children: pages),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 72,
          margin: const EdgeInsets.only(left: 14, right: 14, bottom: 4),
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
          clipBehavior: Clip.hardEdge,

          child: Transform.translate(
            offset: const Offset(0, 7),

            child: CurvedNavigationBar(
              index: currentTabIndex,

              color: Colors.transparent,
              backgroundColor: Colors.transparent,

              height: 60,

              buttonBackgroundColor: Colors.white,

              animationDuration: const Duration(milliseconds: 300),

              animationCurve: Curves.easeInOut,

              onTap: (int index) {
                setState(() {
                  currentTabIndex = index;
                });
              },

              items: const [
                Icon(Icons.home_rounded, size: 23, color: Colors.black87),

                Icon(
                  Icons.shopping_cart_rounded,
                  size: 23,
                  color: Colors.black87,
                ),

                Icon(
                  Icons.receipt_long_rounded,
                  size: 23,
                  color: Colors.black87,
                ),

                Icon(Icons.forum_rounded, size: 23, color: Colors.black87),

                Icon(Icons.person_rounded, size: 23, color: Colors.black87),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
