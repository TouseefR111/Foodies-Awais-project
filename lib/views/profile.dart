import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/views/complaints_screen.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../controller/shared_pref_helper.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? userId;
  String? userName;
  String? userContact;

  // Saved profile picture URL
  String? profileImageUrl;

  bool isLoading = true;
  bool isUploadingImage = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getShareId();
  }

  // ============================================================
  // GET USER DATA
  // ============================================================

  Future<void> getShareId() async {
    try {
      final String? id = await SharedPrefHelper().getUserId();

      final String? name = await SharedPrefHelper().getUserName();

      final String? contact = await SharedPrefHelper().getUserContact();

      String? savedProfileImage;

      if (id != null && id.isNotEmpty) {
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(id)
              .get();

          if (userDoc.exists) {
            final data = userDoc.data();

            if (data != null) {
              savedProfileImage = data['profileImage']?.toString();
            }
          }
        } catch (e) {
          debugPrint('Failed to load profile image: $e');
        }
      }

      if (!mounted) return;

      setState(() {
        userId = id;
        userName = name;
        userContact = contact;
        profileImageUrl = savedProfileImage;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load profile data: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // SHOW IMAGE SOURCE OPTIONS
  // ============================================================

  Future<void> showImageSourceDialog() async {
    if (isUploadingImage) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 1.5.h,
            left: 5.w,
            right: 5.w,
            bottom: 2.h,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // HANDLE
                // ==================================================
                Container(
                  width: 12.w,
                  height: 0.4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                SizedBox(height: 1.5.h),

                Text(
                  'Change Profile Picture',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 1.5.h),

                // ==================================================
                // GALLERY
                // ==================================================
                _imageSourceOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from Gallery',
                  subtitle: 'Select a photo from your device',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(bottomSheetContext);

                    pickImage(ImageSource.gallery);
                  },
                ),

                SizedBox(height: 1.h),

                // ==================================================
                // CAMERA
                // ==================================================
                _imageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  title: 'Take a Photo',
                  subtitle: 'Use your camera to take a photo',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(bottomSheetContext);

                    pickImage(ImageSource.camera);
                  },
                ),

                SizedBox(height: 0.5.h),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // IMAGE SOURCE OPTION
  // ============================================================

  Widget _imageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 11.w,
                height: 11.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 18.sp),
              ),

              SizedBox(width: 3.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 0.2.h),

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

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (pickedFile == null) {
        return;
      }

      await uploadProfileImage(File(pickedFile.path));
    } catch (e) {
      debugPrint('Image picking failed: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to select image',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // UPLOAD PROFILE IMAGE
  // ============================================================

  Future<void> uploadProfileImage(File imageFile) async {
    if (userId == null || userId!.isEmpty) {
      return;
    }

    setState(() {
      isUploadingImage = true;
    });

    try {
      // ==========================================================
      // FIREBASE STORAGE LOCATION
      // ==========================================================

      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      // ==========================================================
      // UPLOAD
      // ==========================================================

      await storageRef.putFile(imageFile);

      // ==========================================================
      // GET DOWNLOAD URL
      // ==========================================================

      final String downloadUrl = await storageRef.getDownloadURL();

      // ==========================================================
      // SAVE URL IN FIRESTORE
      // ==========================================================

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'profileImage': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        profileImageUrl = downloadUrl;
        isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile picture updated successfully',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Profile image upload failed: $e');

      if (!mounted) return;

      setState(() {
        isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to upload profile picture',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  // ============================================================
  // PROFILE MENU CARD
  // ============================================================

  Widget _profileMenuCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.orange,
    bool isDanger = false,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 1.2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDanger ? Colors.red.shade100 : Colors.amber.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
            child: Row(
              children: [
                // ==================================================
                // ICON
                // ==================================================
                Container(
                  width: 11.w,
                  height: 11.w,
                  decoration: BoxDecoration(
                    color: isDanger
                        ? Colors.red.shade50
                        : iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    size: 18.sp,
                    color: isDanger ? Colors.red.shade600 : iconColor,
                  ),
                ),

                SizedBox(width: 3.w),

                // ==================================================
                // TEXT
                // ==================================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: isDanger
                              ? Colors.red.shade700
                              : Colors.black87,
                        ),
                      ),

                      if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                        SizedBox(height: 0.2.h),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: isDanger ? Colors.red.shade400 : Colors.grey.shade400,
                ),
              ],
            ),
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
      backgroundColor: const Color(0xFFFFF9EC),

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,

        title: Text(
          'My Profile',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
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
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.orange.shade700),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              child: Column(
                children: [
                  // ==================================================
                  // PROFILE PICTURE
                  // ==================================================
                  SizedBox(height: 2.h),

                  GestureDetector(
                    onTap: isUploadingImage ? null : showImageSourceDialog,

                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ==================================================
                        // PROFILE IMAGE
                        // ==================================================
                        Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Container(
                            width: 26.w,
                            height: 26.w,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFF3CD),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child:
                                profileImageUrl != null &&
                                    profileImageUrl!.isNotEmpty
                                ? Image.network(
                                    profileImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        'assets/images/profile.png',
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                : Image.asset(
                                    'assets/images/profile.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),

                        // ==================================================
                        // UPLOAD LOADING
                        // ==================================================
                        if (isUploadingImage)
                          Container(
                            width: 26.w,
                            height: 26.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.50),
                            ),
                            child: SizedBox(
                              width: 8.w,
                              height: 8.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          ),

                        // ==================================================
                        // CAMERA BUTTON
                        // ==================================================
                        if (!isUploadingImage)
                          Positioned(
                            right: 1.w,
                            bottom: 1.w,
                            child: Container(
                              width: 9.w,
                              height: 9.w,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD54F),
                                    Color(0xFFFFA000),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 7,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                size: 14.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 1.h),

                  // ==================================================
                  // CHANGE PICTURE TEXT
                  // ==================================================
                  GestureDetector(
                    onTap: isUploadingImage ? null : showImageSourceDialog,
                    child: Text(
                      isUploadingImage
                          ? 'Uploading picture...'
                          : 'Tap to change profile picture',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isUploadingImage
                            ? Colors.grey.shade500
                            : Colors.orange.shade800,
                      ),
                    ),
                  ),

                  SizedBox(height: 1.h),

                  // ==================================================
                  // USER NAME
                  // ==================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Text(
                      (userName == null || userName!.trim().isEmpty)
                          ? 'Foodies User'
                          : userName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  SizedBox(height: 0.5.h),

                  // ==================================================
                  // PHONE
                  // ==================================================
                  if (userContact != null && userContact!.trim().isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          userContact!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 1.h),

                  // ==================================================
                  // ACCOUNT TITLE
                  // ==================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 1.h),

                  // ==================================================
                  // MENU
                  // ==================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Column(
                      children: [
                        // NAME
                        _profileMenuCard(
                          icon: Icons.person_rounded,
                          title: 'Name',
                          subtitle:
                              (userName == null || userName!.trim().isEmpty)
                              ? 'Not available'
                              : userName!,
                          iconColor: Colors.orange,
                          onTap: () {},
                        ),

                        // PHONE
                        _profileMenuCard(
                          icon: Icons.phone_rounded,
                          title: 'Phone Number',
                          subtitle:
                              (userContact == null ||
                                  userContact!.trim().isEmpty)
                              ? 'Not available'
                              : userContact!,
                          iconColor: Colors.green,
                          onTap: () {},
                        ),

                        // TERMS
                        _profileMenuCard(
                          icon: Icons.menu_book_rounded,
                          title: 'Terms & Conditions',
                          subtitle: 'Read our terms and conditions',
                          iconColor: Colors.blue,
                          onTap: () {},
                        ),

                        // COMPLAINTS
                        _profileMenuCard(
                          icon: Icons.forum_rounded,
                          title: 'Complaints',
                          subtitle: 'Submit and track your complaints',
                          iconColor: Colors.deepPurple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ComplaintsScreen(),
                              ),
                            );
                          },
                        ),

                        // DELETE ACCOUNT
                        _profileMenuCard(
                          icon: Icons.delete_outline_rounded,
                          title: 'Delete Account',
                          subtitle: 'Permanently remove your account',
                          isDanger: true,
                          onTap: () {
                            // Keep your existing
                            // delete-account logic here.
                          },
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // LOGOUT
                  // ==================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Container(
                      width: double.infinity,
                      height: 6.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              size: 18.sp,
                              color: Colors.black87,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
    );
  }
}
