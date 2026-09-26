import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/super%20admin/admin_permissions.dart';
import 'package:food_delivery_app/super%20admin/complaints.dart';
import 'package:food_delivery_app/super%20admin/manage_admin.dart';
import 'package:food_delivery_app/super%20admin/super_admin_login.dart';
import 'package:food_delivery_app/super admin/super_admin_chat.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SuperAdminScreen extends StatelessWidget {
  const SuperAdminScreen({super.key});

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SuperAdminLogin()),
      (route) => false,
    );
  }

  // ============================================================
  // MENU CARD
  // ============================================================

  Widget menuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,

      margin: EdgeInsets.only(bottom: 2.h),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,

        child: Padding(
          padding: EdgeInsets.all(4.w),

          child: Row(
            children: [
              // ==================================================
              // ICON
              // ==================================================
              Container(
                width: 15.w,
                height: 15.w,

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(icon, size: 28.sp, color: Colors.black87),
              ),

              SizedBox(width: 4.w),

              // ==================================================
              // TEXT
              // ==================================================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: GoogleFonts.poppins(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 0.5.h),

                    Text(
                      subtitle,

                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.arrow_forward_ios, size: 17.sp),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        toolbarHeight: 9.h,
        // Gradient AppBar
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.elliptical(70, 55),
              bottomRight: Radius.elliptical(70, 55),
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(70, 55),
            bottomRight: Radius.elliptical(70, 55),
          ),
        ),

        elevation: 0,

        automaticallyImplyLeading: false,

        title: Text(
          "Super Admin",
          style: GoogleFonts.poppins(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: true,

        actions: [
          IconButton(
            tooltip: "Logout",

            icon: const Icon(Icons.logout, color: Colors.black),

            onPressed: () {
              showDialog(
                context: context,

                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text("Logout"),

                    content: const Text("Are you sure you want to logout?"),

                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },

                        child: const Text("Cancel"),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          logout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),

                        child: const Text(
                          "Log out",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // HEADER
              // ==================================================
              Text(
                "Welcome, Super Admin",

                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 0.5.h),

              Text(
                "Manage your Foodies application",
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: 4.h),

              // ==================================================
              // MANAGE ADMINS
              // ==================================================
              menuCard(
                context: context,

                icon: Icons.admin_panel_settings_outlined,

                title: "Manage Admins",

                subtitle: "Add, activate, deactivate and manage admins",

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageAdmin(),
                    ),
                  );
                },
              ),
              SizedBox(height: 2.h),

              // ==================================================
              // PERMISSIONS
              // ==================================================
              menuCard(
                context: context,

                icon: Icons.security_outlined,

                title: "Admin Permissions",

                subtitle: "Control what each admin can access",

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminPermissions(),
                    ),
                  );
                },
              ),
              SizedBox(height: 2.h),

              // ==================================================
              // COMPLAINTS
              // ==================================================
              menuCard(
                context: context,

                icon: Icons.support_agent_outlined,

                title: "Complaints",

                subtitle: "View and manage customer complaints",

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Complaints()),
                  );
                },
              ),

              // ============================================================
              // ADMIN CHATS
              // ============================================================
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SuperAdminChat()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),

                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.chat_outlined,
                            color: Colors.black87,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Admin Chats',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Chat with inactive admins',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 17,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==================================================
              // SETTINGS
              // ==================================================
              // menuCard(
              //   context: context,

              //   icon: Icons.settings_outlined,

              //   title: "Settings",

              //   subtitle: "Manage Super Admin settings",

              //   onTap: () {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(
              //         content: Text("Settings will be added here"),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
