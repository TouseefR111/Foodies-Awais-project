import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ManageAdmin extends StatefulWidget {
  const ManageAdmin({super.key});

  @override
  State<ManageAdmin> createState() => _ManageAdminState();
}

class _ManageAdminState extends State<ManageAdmin> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController searchController = TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SHOW MESSAGE
  // ==========================================================

  void showMessage(String message, {Color backgroundColor = Colors.black87}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================
  // ADD ADMIN
  // ==========================================================

  Future<void> addAdmin() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const AddAdminDialog();
      },
    );

    if (result == true && mounted) {
      setState(() {});

      showMessage(
        'Admin added successfully.',
        backgroundColor: Colors.green.shade700,
      );
    }
  }

  // ==========================================================
  // EDIT ADMIN PERMISSIONS
  // ==========================================================

  Future<void> editPermissions(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final data = document.data() ?? {};

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return EditAdminDialog(documentId: document.id, data: data);
      },
    );

    if (result == true && mounted) {
      showMessage(
        'Admin permissions updated successfully.',
        backgroundColor: Colors.green.shade700,
      );
    }
  }

  // ==========================================================
  // DELETE ADMIN
  // ==========================================================

  Future<void> deleteAdmin(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) async {
    final data = document.data() ?? {};

    final String name = data['name']?.toString() ?? 'this admin';

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Delete Admin?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Are you sure you want to delete $name?',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _firestore.collection('Admin').doc(document.id).delete();

      if (!mounted) return;

      showMessage(
        'Admin deleted successfully.',
        backgroundColor: Colors.green.shade700,
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Unable to delete admin.',
        backgroundColor: Colors.red.shade700,
      );
    }
  }

  // ==========================================================
  // CHANGE ACTIVE STATUS
  // ==========================================================

  Future<void> changeAdminStatus(
    DocumentSnapshot<Map<String, dynamic>> document,
    bool currentStatus,
  ) async {
    try {
      await _firestore.collection('Admin').doc(document.id).update({
        'active': !currentStatus,
      });

      if (!mounted) return;

      showMessage(
        currentStatus ? 'Admin deactivated.' : 'Admin activated.',
        backgroundColor: currentStatus
            ? Colors.orange.shade700
            : Colors.green.shade700,
      );
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Unable to change admin status.',
        backgroundColor: Colors.red.shade700,
      );
    }
  }

  // ==========================================================
  // INPUT DECORATION
  // ==========================================================

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.black54),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
      ),
    );
  }

  // ==========================================================
  // PERMISSION CHIP
  // ==========================================================

  Widget permissionChip(String title, bool enabled) {
    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: enabled
            ? Colors.green.withOpacity(0.10)
            : Colors.grey.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: enabled ? Colors.green.shade700 : Colors.grey.shade600,
        ),
      ),
    );
  }

  // ==========================================================
  // ADMIN CARD
  // ==========================================================

  Widget adminCard(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? {};

    final String name = data['name']?.toString() ?? 'No Name';

    final String id = data['id']?.toString() ?? '';

    final String email = data['email']?.toString() ?? '';

    final bool active = data['active'] == true;

    final bool canManageOrders = data['canManageOrders'] == true;

    final bool canManageProducts = data['canManageProducts'] == true;

    final bool canManageUsers = data['canManageUsers'] == true;

    final bool canViewComplaints = data['canViewComplaints'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? Colors.green.withOpacity(0.20)
              : Colors.red.withOpacity(0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // AVATAR
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active
                      ? const Color(0xFFFFC107)
                      : Colors.grey.shade300,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.black87,
                  size: 30,
                ),
              ),

              const SizedBox(width: 14),

              // DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'ID: $id',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // STATUS
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  active ? 'ACTIVE' : 'INACTIVE',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // PERMISSIONS
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              children: [
                permissionChip('Orders', canManageOrders),
                permissionChip('Products', canManageProducts),
                permissionChip('Users', canManageUsers),
                permissionChip('Complaints', canViewComplaints),
              ],
            ),
          ),

          const Divider(height: 25),

          // ACTIONS
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    editPermissions(document);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              Container(width: 1, height: 25, color: Colors.grey.shade300),

              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    changeAdminStatus(document, active);
                  },
                  icon: Icon(
                    active ? Icons.block_outlined : Icons.check_circle_outline,
                    size: 18,
                    color: active ? Colors.orange : Colors.green,
                  ),
                  label: Text(
                    active ? 'Deactivate' : 'Activate',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              ),

              Container(width: 1, height: 25, color: Colors.grey.shade300),

              Expanded(
                child: TextButton.icon(
                  onPressed: () {
                    deleteAdmin(document);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.red,
                  ),
                  label: Text(
                    'Delete',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC107),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Manage Admins',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addAdmin,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: Column(
        children: [
          // SEARCH AREA
          Container(
            width: double.infinity,
            color: const Color(0xFFFFC107),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search admins...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();

                          setState(() {
                            searchText = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ADMIN LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('Admin').snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Text(
                        'Error loading admins:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documents = snapshot.data?.docs ?? [];

                final filteredDocuments = documents.where((document) {
                  final data = document.data();

                  final name = data['name']?.toString().toLowerCase() ?? '';

                  final id = data['id']?.toString().toLowerCase() ?? '';

                  final email = data['email']?.toString().toLowerCase() ?? '';

                  return name.contains(searchText) ||
                      id.contains(searchText) ||
                      email.contains(searchText);
                }).toList();

                if (filteredDocuments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 75,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          searchText.isEmpty
                              ? 'No admins found'
                              : 'No matching admins',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    return adminCard(filteredDocuments[index]);
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

// ============================================================================
// ADD ADMIN DIALOG
// ============================================================================

class AddAdminDialog extends StatefulWidget {
  const AddAdminDialog({super.key});

  @override
  State<AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<AddAdminDialog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController idController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool active = true;

  bool canManageOrders = true;

  bool canManageProducts = true;

  bool canManageUsers = false;

  bool canViewComplaints = false;

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ==========================================================
  // INPUT DECORATION
  // ==========================================================

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
      prefixIcon: Icon(icon, color: Colors.black54),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFC107), width: 1.5),
      ),
    );
  }

  // ==========================================================
  // SAVE ADMIN
  // ==========================================================

  Future<void> saveAdmin() async {
    if (isSaving) {
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final String name = nameController.text.trim();

    final String id = idController.text.trim();

    final String email = emailController.text.trim();

    final String password = passwordController.text.trim();

    try {
      // ========================================================
      // CHECK DUPLICATE ID
      // ========================================================

      final QuerySnapshot<Map<String, dynamic>> idResult = await _firestore
          .collection('Admin')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (idResult.docs.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This Admin ID already exists.')),
        );

        return;
      }

      // ========================================================
      // CHECK DUPLICATE EMAIL
      // ========================================================

      final QuerySnapshot<Map<String, dynamic>> emailResult = await _firestore
          .collection('Admin')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (emailResult.docs.isNotEmpty) {
        if (!mounted) return;

        setState(() {
          isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email already exists.')),
        );

        return;
      }

      // ========================================================
      // CREATE ADMIN DOCUMENT
      // ========================================================

      await _firestore.collection('Admin').add({
        'name': name,
        'id': id,
        'email': email,
        'password': password,
        'role': 'admin',
        'active': active,
        'canManageOrders': canManageOrders,
        'canManageProducts': canManageProducts,
        'canManageUsers': canManageUsers,
        'canViewComplaints': canViewComplaints,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ========================================================
      // IMPORTANT
      //
      // We do NOT show a SnackBar here.
      // We do NOT call anything on the parent.
      //
      // We simply close this dialog.
      // ========================================================

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to add admin.\n$e')));
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      title: Text(
        'Add Admin',
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
      ),

      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // NAME
                TextFormField(
                  controller: nameController,
                  enabled: !isSaving,
                  decoration: inputDecoration(
                    'Admin Name',
                    Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter admin name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // ID
                TextFormField(
                  controller: idController,
                  enabled: !isSaving,
                  decoration: inputDecoration('Admin ID', Icons.badge_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter admin ID';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // EMAIL
                TextFormField(
                  controller: emailController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.emailAddress,
                  decoration: inputDecoration('Email', Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter email';
                    }

                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // PASSWORD
                TextFormField(
                  controller: passwordController,
                  enabled: !isSaving,
                  obscureText: true,
                  decoration: inputDecoration('Password', Icons.lock_outline),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter password';
                    }

                    if (value.trim().length < 4) {
                      return 'Password must be at least 4 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // ACTIVE
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Active',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  value: active,
                  activeColor: Colors.green,
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            active = value;
                          });
                        },
                ),

                const Divider(),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Permissions',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Manage Orders',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  value: canManageOrders,
                  activeColor: Colors.black,
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            canManageOrders = value ?? false;
                          });
                        },
                ),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Manage Products',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  value: canManageProducts,
                  activeColor: Colors.black,
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            canManageProducts = value ?? false;
                          });
                        },
                ),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Manage Users',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  value: canManageUsers,
                  activeColor: Colors.black,
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            canManageUsers = value ?? false;
                          });
                        },
                ),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'View Complaints',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  value: canViewComplaints,
                  activeColor: Colors.black,
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            canViewComplaints = value ?? false;
                          });
                        },
                ),
              ],
            ),
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        ElevatedButton(
          onPressed: isSaving ? null : saveAdmin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Add Admin',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}

// ============================================================================
// EDIT ADMIN DIALOG
// ============================================================================

class EditAdminDialog extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> data;

  const EditAdminDialog({
    super.key,
    required this.documentId,
    required this.data,
  });

  @override
  State<EditAdminDialog> createState() => _EditAdminDialogState();
}

class _EditAdminDialogState extends State<EditAdminDialog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late bool active;
  late bool canManageOrders;
  late bool canManageProducts;
  late bool canManageUsers;
  late bool canViewComplaints;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    active = widget.data['active'] == true;

    canManageOrders = widget.data['canManageOrders'] == true;

    canManageProducts = widget.data['canManageProducts'] == true;

    canManageUsers = widget.data['canManageUsers'] == true;

    canViewComplaints = widget.data['canViewComplaints'] == true;
  }

  // ==========================================================
  // SAVE PERMISSIONS
  // ==========================================================

  Future<void> savePermissions() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      await _firestore.collection('Admin').doc(widget.documentId).update({
        'active': active,
        'canManageOrders': canManageOrders,
        'canManageProducts': canManageProducts,
        'canManageUsers': canManageUsers,
        'canViewComplaints': canViewComplaints,
      });

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update permissions.\n$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      title: Text(
        'Admin Permissions',
        style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w700),
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Active',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              value: active,
              activeColor: Colors.green,
              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() {
                        active = value;
                      });
                    },
            ),

            const Divider(),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Manage Orders',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              value: canManageOrders,
              activeColor: Colors.black,
              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() {
                        canManageOrders = value ?? false;
                      });
                    },
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Manage Products',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              value: canManageProducts,
              activeColor: Colors.black,
              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() {
                        canManageProducts = value ?? false;
                      });
                    },
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Manage Users',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              value: canManageUsers,
              activeColor: Colors.black,
              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() {
                        canManageUsers = value ?? false;
                      });
                    },
            ),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'View Complaints',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              value: canViewComplaints,
              activeColor: Colors.black,
              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() {
                        canViewComplaints = value ?? false;
                      });
                    },
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.grey.shade700),
          ),
        ),

        ElevatedButton(
          onPressed: isSaving ? null : savePermissions,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Save',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
