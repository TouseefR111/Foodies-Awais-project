import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// import 'package:food_delivery_app/views/complaints_screen.dart';
import 'package:food_delivery_app/views/welcome_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

                SizedBox(height: 2.h),

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

                SizedBox(height: 1.5.h),

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

                SizedBox(height: 1.h),
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
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 13.w,
                height: 13.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 21.sp),
              ),

              SizedBox(width: 4.w),

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

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15.sp,
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
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      await storageRef.putFile(imageFile);

      final String downloadUrl = await storageRef.getDownloadURL();

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
  // EDIT NAME
  // ============================================================

  Future<void> showEditNameDialog() async {
    if (userId == null || userId!.isEmpty) {
      return;
    }

    final String? newName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return EditNameDialog(currentName: userName ?? '');
      },
    );

    if (newName == null || newName.trim().isEmpty) {
      return;
    }

    await updateUserName(newName.trim());
  }

  // ============================================================
  // UPDATE NAME
  // ============================================================

  Future<void> updateUserName(String newName) async {
    if (userId == null || userId!.isEmpty) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'name': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(SharedPrefHelper.userKeyName, newName);

      if (!mounted) return;

      setState(() {
        userName = newName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Name updated successfully',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Name update failed: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update name',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // EDIT PHONE
  // ============================================================

  Future<void> showEditPhoneDialog() async {
    if (userId == null || userId!.isEmpty) {
      return;
    }

    final String? newPhone = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return EditPhoneDialog(currentPhone: userContact ?? '');
      },
    );

    if (newPhone == null || newPhone.trim().isEmpty) {
      return;
    }

    await updatePhoneNumber(newPhone.trim());
  }

  // ============================================================
  // UPDATE PHONE
  // ============================================================

  Future<void> updatePhoneNumber(String newPhone) async {
    if (userId == null || userId!.isEmpty) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'phone': newPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString(SharedPrefHelper.userKeyContact, newPhone);

      if (!mounted) return;

      setState(() {
        userContact = newPhone;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Phone number updated successfully',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Phone number update failed: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update phone number',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // DELETE ACCOUNT CONFIRMATION
  // ============================================================

  Future<void> confirmDeleteAccount() async {
    if (userId == null || userId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User account could not be found.',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Container(
                width: 11.w,
                height: 11.w,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red.shade700,
                  size: 20.sp,
                ),
              ),

              SizedBox(width: 3.w),

              Expanded(
                child: Text(
                  'Delete Account?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          content: Text(
            'This will permanently delete your account and personal data.\n\n'
            'Your orders will remain in the system for order records.\n\n'
            'This action cannot be undone.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),

          actionsPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _requestDeletePassword();
  }

  // ============================================================
  // REQUEST PASSWORD
  // ============================================================

  Future<void> _requestDeletePassword() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No logged-in account found.',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final String? password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const DeletePasswordDialog();
      },
    );

    if (password == null || password.trim().isEmpty) {
      return;
    }

    await _deleteAccount(password.trim());
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Future<void> _deleteAccount(String password) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    final String uid = currentUser.uid;

    // Make sure profile UID matches Firebase Auth UID.
    if (userId == null || userId != uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account information is not available. Please log in again.',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // ==========================================================
    // SHOW LOADING
    // ==========================================================

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Row(
              children: [
                SizedBox(
                  width: 7.w,
                  height: 7.w,
                  child: CircularProgressIndicator(
                    color: Colors.orange.shade700,
                    strokeWidth: 3,
                  ),
                ),

                SizedBox(width: 4.w),

                Expanded(
                  child: Text(
                    'Deleting your account...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // ========================================================
      // 1. RE-AUTHENTICATE USER
      // ========================================================

      final String? email = currentUser.email;

      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-email',
          message: 'No email address is associated with this account.',
        );
      }

      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await currentUser.reauthenticateWithCredential(credential);

      // ========================================================
      // 2. DELETE CART ITEMS
      // ========================================================

      final QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('id', isEqualTo: uid)
          .get();

      if (cartSnapshot.docs.isNotEmpty) {
        final WriteBatch cartBatch = FirebaseFirestore.instance.batch();

        for (final doc in cartSnapshot.docs) {
          cartBatch.delete(doc.reference);
        }

        await cartBatch.commit();
      }

      // ========================================================
      // 3. DELETE USER COMPLAINTS
      // ========================================================

      final QuerySnapshot complaintsSnapshot = await FirebaseFirestore.instance
          .collection('Complaints')
          .where('userId', isEqualTo: uid)
          .get();

      if (complaintsSnapshot.docs.isNotEmpty) {
        final WriteBatch complaintsBatch = FirebaseFirestore.instance.batch();

        for (final doc in complaintsSnapshot.docs) {
          complaintsBatch.delete(doc.reference);
        }

        await complaintsBatch.commit();
      }

      // ========================================================
      // 4. DELETE PROFILE IMAGE
      // ========================================================

      try {
        final Reference profileImageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('$uid.jpg');

        await profileImageRef.delete();
      } on FirebaseException catch (e) {
        // If the image doesn't exist, continue.
        if (e.code != 'object-not-found') {
          debugPrint('Profile image deletion failed: ${e.message}');
        }
      }

      // ========================================================
      // 5. DELETE USER FIRESTORE DOCUMENT
      // ========================================================

      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // ========================================================
      // 6. DELETE FIREBASE AUTH ACCOUNT
      // ========================================================

      await currentUser.delete();

      // ========================================================
      // 7. CLEAR LOCAL USER DATA
      // ========================================================

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.clear();

      // ========================================================
      // 8. CLOSE LOADING DIALOG
      // ========================================================

      if (!mounted) return;

      Navigator.of(context).pop();

      // ========================================================
      // 9. GO TO WELCOME SCREEN
      // ========================================================

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase delete account error: ${e.code}');

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      String message;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Incorrect password. Account was not deleted.';
          break;

        case 'requires-recent-login':
          message = 'Please log in again and then try deleting your account.';
          break;

        case 'user-mismatch':
          message = 'This account does not match the current profile.';
          break;

        case 'user-not-found':
          message = 'User account was not found.';
          break;

        case 'network-request-failed':
          message = 'Network error. Please check your internet connection.';
          break;

        default:
          message = e.message ?? 'Failed to delete the account.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(fontSize: 14.sp)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint('Delete account error: $e');

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account deletion failed. Please try again.',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          titlePadding: EdgeInsets.fromLTRB(6.w, 2.5.h, 6.w, 0),
          contentPadding: EdgeInsets.fromLTRB(6.w, 1.5.h, 6.w, 1.h),
          actionsPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),

          title: Row(
            children: [
              Container(
                width: 11.w,
                height: 11.w,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.orange.shade700,
                  size: 20.sp,
                ),
              ),

              SizedBox(width: 3.w),

              Expanded(
                child: Text(
                  'Logout?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          content: Text(
            'Are you sure you want to logout from your account?',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            Container(
              height: 5.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.black87,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDanger ? Colors.red.shade100 : Colors.amber.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            child: Row(
              children: [
                Container(
                  width: 11.w,
                  height: 11.w,
                  decoration: BoxDecoration(
                    color: isDanger
                        ? Colors.red.shade50
                        : iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 18.sp,
                    color: isDanger ? Colors.red.shade600 : iconColor,
                  ),
                ),

                SizedBox(width: 4.w),

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
                        SizedBox(height: 0.4.h),

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
                  size: 15.sp,
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
        toolbarHeight: 9.h,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,

        title: Text(
          'My Profile',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
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
                  SizedBox(height: 2.h),

                  // ==================================================
                  // PROFILE PICTURE
                  // ==================================================
                  GestureDetector(
                    onTap: isUploadingImage ? null : showImageSourceDialog,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(1.2.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 18,
                                offset: const Offset(0, 7),
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
                              width: 9.w,
                              height: 9.w,
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
                                    blurRadius: 8,
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
                  // CLICK TEXT
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

                  SizedBox(height: 1.h),

                  if (userContact != null && userContact!.trim().isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: 15.sp,
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
                  // ACCOUNT
                  // ==================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'USER INFO',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 1.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Column(
                      children: [
                        // ==================================================
                        // NAME
                        // ==================================================
                        _profileMenuCard(
                          icon: Icons.person_rounded,
                          title: 'Name',
                          subtitle:
                              (userName == null || userName!.trim().isEmpty)
                              ? 'Not available'
                              : userName!,
                          iconColor: Colors.orange,
                          onTap: showEditNameDialog,
                        ),
                        SizedBox(height: 1.h),

                        // ==================================================
                        // PHONE
                        // ==================================================
                        _profileMenuCard(
                          icon: Icons.phone_rounded,
                          title: 'Phone Number',
                          subtitle:
                              (userContact == null ||
                                  userContact!.trim().isEmpty)
                              ? 'Not available'
                              : userContact!,
                          iconColor: Colors.green,
                          onTap: showEditPhoneDialog,
                        ),
                        SizedBox(height: 1.h),

                        // ==================================================
                        // TERMS
                        // ==================================================
                        _profileMenuCard(
                          icon: Icons.menu_book_rounded,
                          title: 'Terms & Conditions',
                          subtitle: 'Read our terms and conditions',
                          iconColor: Colors.blue,
                          onTap: () {},
                        ),

                        // ==================================================
                        // COMPLAINTS
                        // ==================================================
                        // _profileMenuCard(
                        //   icon: Icons.forum_rounded,
                        //   title: 'Complaints',
                        //   subtitle: 'Submit and track your complaints',
                        //   iconColor: Colors.deepPurple,
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => const ComplaintsScreen(),
                        //       ),
                        //     );
                        //   },
                        // ),
                        SizedBox(height: 1.h),

                        // ==================================================
                        // DELETE ACCOUNT
                        // ==================================================
                        _profileMenuCard(
                          icon: Icons.delete_outline_rounded,
                          title: 'Delete Account',
                          subtitle: 'Permanently remove your account',
                          isDanger: true,
                          onTap: confirmDeleteAccount,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

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
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
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
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              size: 20.sp,
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

                  SizedBox(height: 1.h),
                ],
              ),
            ),
    );
  }
}

// ================================================================
// EDIT NAME DIALOG
// ================================================================

class EditNameDialog extends StatefulWidget {
  final String currentName;

  const EditNameDialog({super.key, required this.currentName});

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late final TextEditingController nameController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        'Edit Name',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Name is required';
            }

            if (value.trim().length < 2) {
              return 'Name must contain at least 2 characters';
            }

            return null;
          },
        ),
      ),
      actionsPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, nameController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Save',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// EDIT PHONE DIALOG
// ================================================================

class EditPhoneDialog extends StatefulWidget {
  final String currentPhone;

  const EditPhoneDialog({super.key, required this.currentPhone});

  @override
  State<EditPhoneDialog> createState() => _EditPhoneDialogState();
}

class _EditPhoneDialogState extends State<EditPhoneDialog> {
  late final TextEditingController phoneController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    phoneController = TextEditingController(text: widget.currentPhone);
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        'Edit Phone Number',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            prefixIcon: const Icon(Icons.phone_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }

            if (value.trim().length < 7) {
              return 'Enter a valid phone number';
            }

            return null;
          },
        ),
      ),
      actionsPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, phoneController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Save',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// DELETE PASSWORD DIALOG
// ================================================================

class DeletePasswordDialog extends StatefulWidget {
  const DeletePasswordDialog({super.key});

  @override
  State<DeletePasswordDialog> createState() => _DeletePasswordDialogState();
}

class _DeletePasswordDialogState extends State<DeletePasswordDialog> {
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool obscurePassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        'Confirm Your Password',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),

      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'For security, enter your current password to permanently delete your account.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),

            SizedBox(height: 2.h),

            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, passwordController.text.trim());
                }
              },
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.orange.shade700,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required';
                }

                return null;
              },
            ),
          ],
        ),
      ),

      actionsPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),

        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, passwordController.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Delete Account',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
