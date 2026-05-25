import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/admin/admin_login.dart';
import 'package:food_delivery_app/views/cart_screen.dart';
import 'package:food_delivery_app/views/food_cart.dart';
import 'package:food_delivery_app/views/home_screen.dart';
import 'package:food_delivery_app/views/my cart.dart';
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
    // TODO: implement initState
    super.initState();
    homeScreen = const HomeScreen();
    cartScreen = const CartScreen();
    myOrder = const MyOrder();
    profile = const Profile();
    pages= [homeScreen,cartScreen,myOrder,profile];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.amber,
        backgroundColor: Colors.white,
        // animationDuration: Duration(microseconds: 3),
        onTap: (int index){
          setState(() {
            currentTabIndex = index;
          });
        },
        items: const [
          Icon(Icons.home,color: Colors.black,),
          Icon(Icons.shopping_cart,color: Colors.black,),
          Icon(Icons.list_alt_outlined,color: Colors.black,),
          Icon(Icons.person,color: Colors.black,),
        ],
      ),
      body: pages[currentTabIndex],

    );
  }
}
