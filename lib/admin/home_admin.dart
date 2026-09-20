import 'package:flutter/material.dart';

import 'package:food_delivery_app/admin/add_deal.dart';
import 'package:food_delivery_app/admin/add_product.dart';
import 'package:food_delivery_app/admin/all_orders.dart';
import 'package:food_delivery_app/admin/deal_manage.dart';
import 'package:food_delivery_app/admin/product_list_screen.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';

import 'package:sizer/sizer.dart';

class HomeAdmin extends StatefulWidget {
  final String adminDocumentId;
  final Map<String, dynamic> adminData;

  const HomeAdmin({
    super.key,
    required this.adminDocumentId,
    required this.adminData,
  });

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  bool isLoading = true;

  bool canManageOrders = false;
  bool canManageProducts = false;
  bool canManageUsers = false;
  bool canViewComplaints = false;

  String adminName = 'Admin';

  @override
  void initState() {
    super.initState();

    loadPermissions();
  }

  // ============================================================
  // LOAD PERMISSIONS
  // ============================================================

  void loadPermissions() {
    final data = widget.adminData;

    debugPrint('======================================');
    debugPrint('ADMIN LOGGED IN');
    debugPrint('Document ID: ${widget.adminDocumentId}');
    debugPrint('Admin Name: ${data['name']}');
    debugPrint('Orders: ${data['canManageOrders']}');
    debugPrint('Products: ${data['canManageProducts']}');
    debugPrint('Users: ${data['canManageUsers']}');
    debugPrint('Complaints: ${data['canViewComplaints']}');
    debugPrint('======================================');

    setState(() {
      adminName = data['name']?.toString() ?? 'Admin';

      canManageOrders = data['canManageOrders'] == true;

      canManageProducts = data['canManageProducts'] == true;

      canManageUsers = data['canManageUsers'] == true;

      canViewComplaints = data['canViewComplaints'] == true;

      isLoading = false;
    });
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  void logoutUser() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================
      // PROFESSIONAL BACKGROUND
      // ========================================================
      backgroundColor: const Color(0xFFFFF8E7),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        elevation: 0,

        iconTheme: const IconThemeData(color: Colors.black87),

        toolbarHeight: 10.h,

        // Gradient AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "ADMIN DASHBOARD",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18.sp,
                color: Colors.black87,
                letterSpacing: 0.8,
              ),
            ),

            // const SizedBox(height: 3),

            // Text(
            //   adminName,
            //   style: TextStyle(
            //     fontSize: 14.sp,
            //     fontWeight: FontWeight.w500,
            //     color: Colors.black87,
            //   ),
            // ),
          ],
        ),

        centerTitle: true,

        // ======================================================
        // LOGOUT BUTTON
        // ======================================================
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(
                Icons.logout_rounded,
                color: Colors.black87,
                size: 25,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),

                    title: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    content: const Text('Are you sure you want to logout?'),

                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          logoutUser();
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
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

      // ========================================================
      // BODY
      // ========================================================
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9800)),
            )
          : _buildDashboard(),
    );
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget _buildDashboard() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),

      child: Column(
        children: [
          // ====================================================
          // WELCOME HEADER
          // ====================================================
          Padding(
            padding: EdgeInsets.only(
              top: 2.5.h,
              left: 7.w,
              right: 7.w,
              bottom: 1.h,
            ),

            child: Align(
              alignment: Alignment.centerLeft,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Welcome, $adminName",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3E2723),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Manage your Foodies dashboard",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.brown.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // ====================================================
          // PRODUCT PERMISSIONS
          // ====================================================
          if (canManageProducts) ...[
            // ==================================================
            // ADD ITEM
            // ==================================================
            _dashboardButton(
              color: const Color(0xFFFFA000),
              image: "assets/images/pizza.png",
              title: "Add Item",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddProduct()),
                );
              },
            ),

            SizedBox(height: 2.h),

            // ==================================================
            // MANAGE ITEMS
            // ==================================================
            _dashboardButton(
              color: const Color(0xFFFF6D00),
              image: "assets/images/pizza.png",
              title: "Manage Items",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductListScreen(),
                  ),
                );
              },
            ),

            SizedBox(height: 2.h),

            // ==================================================
            // ADD DEAL
            // ==================================================
            _dashboardButton(
              color: const Color(0xFFE65100),
              icon: Icons.local_offer_rounded,
              title: "Add Deal",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddDeal()),
                );
              },
            ),

            SizedBox(height: 2.h),

            // ==================================================
            // MANAGE DEALS
            // ==================================================
            _dashboardButton(
              color: const Color(0xFFFF8F00),
              icon: Icons.local_offer_rounded,
              title: "Manage Deals",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DealManageScreen()),
                );
              },
            ),

            SizedBox(height: 2.5.h),
          ],

          // ====================================================
          // ORDER PERMISSION
          // ====================================================
          if (canManageOrders)
            _dashboardButton(
              color: const Color(0xFFEF6C00),
              image: "assets/images/order.png",
              title: "All Orders",

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllOrders()),
                );
              },
            ),

          // ====================================================
          // NO PERMISSIONS
          // ====================================================
          if (!canManageProducts && !canManageOrders)
            Padding(
              padding: EdgeInsets.only(top: 12.h, left: 30, right: 30),

              child: Container(
                width: double.infinity,

                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 35,
                ),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),

                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  border: Border.all(color: const Color(0xFFFFCC80)),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.12),

                      blurRadius: 12,

                      offset: const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.65),

                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.lock_outline_rounded,

                        size: 55,

                        color: Colors.orange.shade700,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'No Permissions Assigned',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,

                        color: Color(0xFF4E342E),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Please contact the Super Admin '
                      'to get access.',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 14,

                        color: Colors.brown.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  // ============================================================
  // DASHBOARD BUTTON
  // ============================================================

  Widget _dashboardButton({
    required Color color,
    required String title,
    required VoidCallback onTap,
    String? image,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w),

      child: GestureDetector(
        onTap: onTap,

        child: Container(
          width: MediaQuery.of(context).size.width,

          height: 12.h,

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            // ==================================================
            // GRADIENT
            // ==================================================
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFFF8F00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),

            // ==================================================
            // SHADOW
            // ==================================================
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),

                blurRadius: 5,

                offset: const Offset(0, 7),
              ),
            ],
          ),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),

            child: Row(
              children: [
                // ============================================
                // IMAGE
                // ============================================
                if (image != null)
                  Container(
                    width: 27.w,

                    height: double.infinity,

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(10),

                      child: Image.asset(image, fit: BoxFit.contain),
                    ),
                  ),

                // ============================================
                // ICON
                // ============================================
                if (icon != null)
                  Container(
                    width: 27.w,

                    height: double.infinity,

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                    ),

                    child: Icon(icon, color: Colors.white, size: 48),
                  ),

                // ============================================
                // TITLE
                // ============================================
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),

                    child: Text(
                      title,

                      style: TextStyle(
                        fontSize: 18.sp,

                        fontWeight: FontWeight.w700,

                        color: Colors.black87,

                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                // ============================================
                // ARROW
                // ============================================
                const Padding(
                  padding: EdgeInsets.only(right: 18),

                  child: Icon(
                    Icons.arrow_forward_ios_rounded,

                    color: Colors.black87,

                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
