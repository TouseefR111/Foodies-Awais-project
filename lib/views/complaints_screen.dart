import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../controller/shared_pref_helper.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final TextEditingController subjectController = TextEditingController();

  final TextEditingController orderIdController = TextEditingController();

  final TextEditingController messageController = TextEditingController();

  String? userId;
  String? userName;
  String? userContact;
  String? userEmail;

  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // ============================================================
  // LOAD USER DATA
  // ============================================================

  Future<void> loadUserData() async {
    try {
      userId = await SharedPrefHelper().getUserId();
      userName = await SharedPrefHelper().getUserName();
      userContact = await SharedPrefHelper().getUserContact();

      userEmail = FirebaseAuth.instance.currentUser?.email;

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // SUBMIT COMPLAINT
  // ============================================================

  Future<void> submitComplaint() async {
    if (subjectController.text.trim().isEmpty) {
      showMessage('Please enter a subject');
      return;
    }

    if (messageController.text.trim().isEmpty) {
      showMessage('Please enter your complaint');
      return;
    }

    if (userId == null || userId!.isEmpty) {
      showMessage('User information not found. Please login again.');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('Complaints').add({
        'userId': userId ?? '',
        'userName': userName ?? '',
        'userEmail': userEmail ?? '',
        'phone': userContact ?? '',
        'subject': subjectController.text.trim(),
        'message': messageController.text.trim(),
        'orderId': orderIdController.text.trim(),
        'status': 'Pending',
        'adminReply': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      subjectController.clear();
      orderIdController.clear();
      messageController.clear();

      showMessage('Complaint submitted successfully', isError: false);

      // The newly submitted complaint will
      // automatically appear in My Complaints
      // because the StreamBuilder listens to Firestore.
    } catch (e) {
      if (!mounted) {
        return;
      }

      showMessage('Failed to submit complaint: $e');
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        isSubmitting = false;
      });
    }
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.amber, width: 2),
        ),
      ),
    );
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;

      case 'In Progress':
        return Colors.blue;

      case 'Resolved':
        return Colors.green;

      case 'Rejected':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Date unavailable';
    }

    final DateTime date = timestamp.toDate();

    final String day = date.day.toString().padLeft(2, '0');

    final String month = date.month.toString().padLeft(2, '0');

    final String year = date.year.toString();

    final String hour = date.hour.toString().padLeft(2, '0');

    final String minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  // ============================================================
  // COMPLAINT CARD
  // ============================================================

  Widget complaintCard(QueryDocumentSnapshot document) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    final String subject = (data['subject'] ?? 'No subject').toString();

    final String message = (data['message'] ?? '').toString();

    final String orderId = (data['orderId'] ?? '').toString();

    final String status = (data['status'] ?? 'Pending').toString();

    final String adminReply = (data['adminReply'] ?? '').toString();

    final Timestamp? createdAt = data['createdAt'] is Timestamp
        ? data['createdAt'] as Timestamp
        : null;

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // SUBJECT + STATUS
            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    subject,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 1.h),

            // ==================================================
            // DATE
            // ==================================================
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  formatDate(createdAt),
                  style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                ),
              ],
            ),

            SizedBox(height: 1.5.h),

            // ==================================================
            // ORDER ID
            // ==================================================
            if (orderId.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Order ID: $orderId',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            if (orderId.isNotEmpty) SizedBox(height: 1.5.h),

            // ==================================================
            // CUSTOMER MESSAGE
            // ==================================================
            const Text(
              'Your Complaint',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 0.7.h),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(message),
            ),

            SizedBox(height: 1.5.h),

            // ==================================================
            // ADMIN REPLY
            // ==================================================
            const Text(
              'Admin Reply',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 0.7.h),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: adminReply.isEmpty
                    ? Colors.grey.shade100
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: adminReply.isEmpty
                      ? Colors.grey.shade300
                      : Colors.green.shade200,
                ),
              ),
              child: Text(
                adminReply.isEmpty
                    ? 'No reply yet. Our team is reviewing your complaint.'
                    : adminReply,
                style: TextStyle(
                  color: adminReply.isEmpty
                      ? Colors.grey.shade700
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    subjectController.dispose();
    orderIdController.dispose();
    messageController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complaints',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Complaints')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 3.h,
                    ),
                    child: buildComplaintForm(showComplaintsLoading: true),
                  );
                }

                if (snapshot.hasError) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 3.h,
                    ),
                    child: Column(
                      children: [
                        buildComplaintForm(),

                        SizedBox(height: 3.h),

                        const Text(
                          'Unable to load your complaints.',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final List<QueryDocumentSnapshot> complaints =
                    snapshot.data?.docs ?? [];

                // Sort locally by createdAt.
                // This avoids needing a Firestore
                // composite index.
                complaints.sort((a, b) {
                  final Map<String, dynamic> dataA =
                      a.data() as Map<String, dynamic>;

                  final Map<String, dynamic> dataB =
                      b.data() as Map<String, dynamic>;

                  final Timestamp? timeA = dataA['createdAt'] is Timestamp
                      ? dataA['createdAt'] as Timestamp
                      : null;

                  final Timestamp? timeB = dataB['createdAt'] is Timestamp
                      ? dataB['createdAt'] as Timestamp
                      : null;

                  if (timeA == null && timeB == null) {
                    return 0;
                  }

                  if (timeA == null) {
                    return 1;
                  }

                  if (timeB == null) {
                    return -1;
                  }

                  return timeB.compareTo(timeA);
                });

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // FORM
                      // ==================================================
                      buildComplaintForm(),

                      SizedBox(height: 4.h),

                      // ==================================================
                      // MY COMPLAINTS TITLE
                      // ==================================================
                      Row(
                        children: [
                          const Icon(Icons.history, size: 25),
                          SizedBox(width: 2.w),
                          const Text(
                            'My Complaints',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 1.5.h),

                      // ==================================================
                      // NO COMPLAINTS
                      // ==================================================
                      if (complaints.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(5.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                size: 45,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'You have not submitted any complaints yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                      // ==================================================
                      // COMPLAINT LIST
                      // ==================================================
                      if (complaints.isNotEmpty)
                        ...complaints.map(
                          (document) => complaintCard(document),
                        ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // ============================================================
  // COMPLAINT FORM
  // ============================================================

  Widget buildComplaintForm({bool showComplaintsLoading = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.amber),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit a Complaint',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Tell us about your problem and our team will review it.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        buildTextField(
          controller: subjectController,
          label: 'Subject',
          hint: 'Enter complaint subject',
          icon: Icons.subject,
        ),

        SizedBox(height: 2.h),

        buildTextField(
          controller: orderIdController,
          label: 'Order ID (Optional)',
          hint: 'Enter your order ID',
          icon: Icons.receipt_long,
        ),

        SizedBox(height: 2.h),

        buildTextField(
          controller: messageController,
          label: 'Complaint',
          hint: 'Describe your complaint',
          icon: Icons.comment,
          maxLines: 6,
        ),

        SizedBox(height: 3.h),

        SizedBox(
          width: double.infinity,
          height: 6.5.h,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : submitComplaint,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.black,
                    ),
                  )
                : const Text(
                    'Submit Complaint',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
          ),
        ),

        if (showComplaintsLoading)
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          ),

        SizedBox(height: 2.h),

        Center(
          child: Text(
            'Your complaint will be sent to the administration.',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
