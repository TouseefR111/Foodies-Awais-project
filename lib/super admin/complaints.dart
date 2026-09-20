import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Complaints extends StatefulWidget {
  const Complaints({super.key});

  @override
  State<Complaints> createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaints> {
  final TextEditingController searchController = TextEditingController();

  String selectedStatus = 'All';

  final List<String> statusList = [
    'All',
    'Pending',
    'In Progress',
    'Resolved',
    'Rejected',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // SEARCH
  // ------------------------------------------------------------

  bool matchesSearch(Map<String, dynamic> data) {
    final String search = searchController.text.trim().toLowerCase();

    if (search.isEmpty) {
      return true;
    }

    final String userName = (data['userName'] ?? '').toString().toLowerCase();

    final String userEmail = (data['userEmail'] ?? '').toString().toLowerCase();

    final String subject = (data['subject'] ?? '').toString().toLowerCase();

    final String orderId = (data['orderId'] ?? '').toString().toLowerCase();

    final String message = (data['message'] ?? '').toString().toLowerCase();

    return userName.contains(search) ||
        userEmail.contains(search) ||
        subject.contains(search) ||
        orderId.contains(search) ||
        message.contains(search);
  }

  // ------------------------------------------------------------
  // STATUS COLOR
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // UPDATE STATUS
  // ------------------------------------------------------------

  Future<void> updateStatus(String complaintId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('Complaints')
          .doc(complaintId)
          .update({'status': status});

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complaint marked as $status'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // REPLY DIALOG
  // ------------------------------------------------------------

  Future<void> showReplyDialog(String complaintId, String currentReply) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AdminReplyDialog(
          complaintId: complaintId,
          currentReply: currentReply,
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // COMPLAINT DETAILS
  // ------------------------------------------------------------

  void showComplaintDetails(String complaintId, Map<String, dynamic> data) {
    final String userName = (data['userName'] ?? 'Unknown').toString();

    final String userEmail = (data['userEmail'] ?? 'Not available').toString();

    final String phone = (data['phone'] ?? 'Not available').toString();

    final String subject = (data['subject'] ?? 'No subject').toString();

    final String message = (data['message'] ?? 'No message').toString();

    final String orderId = (data['orderId'] ?? '').toString();

    final String status = (data['status'] ?? 'Pending').toString();

    final String adminReply = (data['adminReply'] ?? '').toString();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Complaint Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                detailItem('Customer', userName),

                detailItem('Email', userEmail),

                detailItem('Phone', phone),

                detailItem('Subject', subject),

                detailItem(
                  'Order ID',
                  orderId.isEmpty ? 'Not provided' : orderId,
                ),

                detailItem('Status', status),

                const SizedBox(height: 12),

                const Text(
                  'Complaint:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(message),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Admin Reply:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(adminReply.isEmpty ? 'No reply yet' : adminReply),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();

                // Open reply dialog after the details
                // dialog has completely closed.
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (!mounted) {
                    return;
                  }

                  showReplyDialog(complaintId, adminReply);
                });
              },
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // DETAIL ITEM
  // ------------------------------------------------------------

  Widget detailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STATUS DROPDOWN
  // ------------------------------------------------------------

  Widget statusDropdown(String complaintId, String currentStatus) {
    final String validStatus = statusList.contains(currentStatus)
        ? currentStatus
        : 'Pending';

    return DropdownButton<String>(
      value: validStatus,
      underline: const SizedBox(),

      items: statusList.where((status) => status != 'All').map((status) {
        return DropdownMenuItem<String>(
          value: status,
          child: Text(
            status,
            style: TextStyle(
              color: statusColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        );
      }).toList(),

      onChanged: (value) {
        if (value != null && value != currentStatus) {
          updateStatus(complaintId, value);
        }
      },
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complaints',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ----------------------------------------------------
          // SEARCH FIELD
          // ----------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {});
              },

              decoration: InputDecoration(
                hintText: 'Search name, email, subject or order ID',

                prefixIcon: const Icon(Icons.search),

                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();

                          setState(() {});
                        },
                      )
                    : null,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // ----------------------------------------------------
          // STATUS FILTER
          // ----------------------------------------------------
          SizedBox(
            height: 50,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,

              padding: const EdgeInsets.symmetric(horizontal: 10),

              itemCount: statusList.length,

              itemBuilder: (context, index) {
                final String status = statusList[index];

                final bool selected = selectedStatus == status;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),

                  child: ChoiceChip(
                    label: Text(status),

                    selected: selected,

                    selectedColor: status == 'All'
                        ? Colors.amber
                        : statusColor(status),

                    labelStyle: TextStyle(
                      color: selected ? Colors.black : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),

                    onSelected: (_) {
                      setState(() {
                        selectedStatus = status;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ----------------------------------------------------
          // COMPLAINTS LIST
          // ----------------------------------------------------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Complaints')
                  .snapshots(),

              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error loading complaints:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // No complaints
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No complaints found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                // Filter complaints
                final List<QueryDocumentSnapshot> documents = snapshot
                    .data!
                    .docs
                    .where((doc) {
                      final Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;

                      final String status = (data['status'] ?? 'Pending')
                          .toString();

                      // Status filter
                      if (selectedStatus != 'All' && status != selectedStatus) {
                        return false;
                      }

                      // Search filter
                      return matchesSearch(data);
                    })
                    .toList();

                // No matching complaints
                if (documents.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching complaints',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                // List
                return ListView.builder(
                  padding: const EdgeInsets.all(15),

                  itemCount: documents.length,

                  itemBuilder: (context, index) {
                    final QueryDocumentSnapshot doc = documents[index];

                    final Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    final String complaintId = doc.id;

                    final String userName = (data['userName'] ?? 'Unknown')
                        .toString();

                    final String subject = (data['subject'] ?? 'No subject')
                        .toString();

                    final String message = (data['message'] ?? '').toString();

                    final String orderId = (data['orderId'] ?? '').toString();

                    final String status = (data['status'] ?? 'Pending')
                        .toString();

                    final String adminReply = (data['adminReply'] ?? '')
                        .toString();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),

                      elevation: 4,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(15),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // --------------------------------
                            // SUBJECT + STATUS
                            // --------------------------------
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Expanded(
                                  child: Text(
                                    subject,

                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),

                                  decoration: BoxDecoration(
                                    color: statusColor(
                                      status,
                                    ).withOpacity(0.15),

                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Text(
                                    status,

                                    style: TextStyle(
                                      color: statusColor(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // --------------------------------
                            // CUSTOMER
                            // --------------------------------
                            Text(
                              'Customer: $userName',

                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            // --------------------------------
                            // ORDER ID
                            // --------------------------------
                            if (orderId.isNotEmpty) ...[
                              const SizedBox(height: 4),

                              Text('Order ID: $orderId'),
                            ],

                            const SizedBox(height: 8),

                            // --------------------------------
                            // MESSAGE
                            // --------------------------------
                            Text(
                              message,

                              maxLines: 3,

                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(color: Colors.black87),
                            ),

                            const SizedBox(height: 10),

                            // --------------------------------
                            // ADMIN REPLY
                            // --------------------------------
                            if (adminReply.isNotEmpty)
                              Container(
                                width: double.infinity,

                                padding: const EdgeInsets.all(10),

                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,

                                  borderRadius: BorderRadius.circular(8),
                                ),

                                child: Text(
                                  'Admin Reply: $adminReply',

                                  maxLines: 2,

                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                            const SizedBox(height: 10),

                            // --------------------------------
                            // ACTIONS
                            // --------------------------------
                            Row(
                              children: [
                                Expanded(
                                  child: statusDropdown(complaintId, status),
                                ),

                                IconButton(
                                  tooltip: 'View Details',

                                  icon: const Icon(Icons.visibility),

                                  onPressed: () {
                                    showComplaintDetails(complaintId, data);
                                  },
                                ),

                                IconButton(
                                  tooltip: 'Reply',

                                  icon: const Icon(Icons.reply),

                                  onPressed: () {
                                    showReplyDialog(complaintId, adminReply);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN REPLY DIALOG
// ============================================================

class AdminReplyDialog extends StatefulWidget {
  final String complaintId;
  final String currentReply;

  const AdminReplyDialog({
    super.key,
    required this.complaintId,
    required this.currentReply,
  });

  @override
  State<AdminReplyDialog> createState() => _AdminReplyDialogState();
}

class _AdminReplyDialogState extends State<AdminReplyDialog> {
  late final TextEditingController replyController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    replyController = TextEditingController(text: widget.currentReply);
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // SAVE REPLY
  // ----------------------------------------------------------

  Future<void> saveReply() async {
    final String reply = replyController.text.trim();

    if (reply.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a reply'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Complaints')
          .doc(widget.complaintId)
          .update({'adminReply': reply});

      if (!mounted) {
        return;
      }

      // Close the dialog only after Firestore
      // successfully completes.
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save reply: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // BUILD DIALOG
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Admin Reply',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),

      content: TextField(
        controller: replyController,

        enabled: !isSaving,

        maxLines: 6,

        decoration: InputDecoration(
          hintText: 'Write your reply...',

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,

            foregroundColor: Colors.black,
          ),

          onPressed: isSaving ? null : saveReply,

          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text('Save Reply'),
        ),
      ],
    );
  }
}
