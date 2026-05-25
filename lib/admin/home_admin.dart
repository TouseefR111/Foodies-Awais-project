import 'package:flutter/material.dart';
import 'package:food_delivery_app/admin/add_product.dart';
import 'package:food_delivery_app/admin/all_orders.dart';
import 'package:food_delivery_app/admin/product_list_screen.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';
import 'package:sizer/sizer.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {

  void logoutUser() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen())); // Navigate to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        toolbarHeight: 10.h,
        backgroundColor: Colors.black,
        title: Text(
          "admin Dashboard".toUpperCase(),
          style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15.sp,
              color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
                size: 25,
              ),
              onPressed: () {
                // Show Logout Confirmation Dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          // Add your logout logic here
                          logoutUser();
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 3.h,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddProduct()));
              },
              child: Material(
                elevation: 7.0,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/pizza.png"),
                      Text("Add Item",style: TextStyle(fontSize: 20.sp,fontWeight: FontWeight.bold,color: Colors.white),)
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductListScreen()));
              },
              child: Material(
                elevation: 7.0,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/images/pizza.png"),
                      Text("Manage Items",style: TextStyle(fontSize: 20.sp,fontWeight: FontWeight.bold,color: Colors.white),)
                    ],
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 4.h,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllOrders()));
              },
              child: Material(
                elevation: 7.0,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                          child: Image.asset("assets/images/order.png")),
                      Text("All Orders",style: TextStyle(fontSize: 20.sp,fontWeight: FontWeight.bold,color: Colors.white),)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
