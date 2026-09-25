import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AdminPermissions extends StatefulWidget {
  const AdminPermissions({super.key});

  @override
  State<AdminPermissions> createState() => _AdminPermissionsState();
}

class _AdminPermissionsState extends State<AdminPermissions> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        toolbarHeight: 9.h,
        elevation: 0,
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
        title: const Text(
          'Admin Permissions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search admin...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ADMIN LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Admin').snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No admins found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                final admins = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final name = (data['name'] ?? '').toString().toLowerCase();

                  final id = (data['id'] ?? '').toString().toLowerCase();

                  final email = (data['email'] ?? '').toString().toLowerCase();

                  return name.contains(searchText) ||
                      id.contains(searchText) ||
                      email.contains(searchText);
                }).toList();

                if (admins.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching admin found',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    final doc = admins[index];

                    final data = doc.data() as Map<String, dynamic>;

                    return _adminCard(context, doc.id, data);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminCard(
    BuildContext context,
    String documentId,
    Map<String, dynamic> data,
  ) {
    final String name = data['name'] ?? 'Unknown Admin';
    final String id = data['id'] ?? 'No ID';
    final String email = data['email'] ?? 'No email';

    final bool active = data['active'] ?? true;

    final bool canManageOrders = data['canManageOrders'] ?? false;

    final bool canManageProducts = data['canManageProducts'] ?? false;

    final bool canManageUsers = data['canManageUsers'] ?? false;

    final bool canViewComplaints = data['canViewComplaints'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ADMIN INFORMATION
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.orange.shade100,
                  child: const Icon(
                    Icons.person,
                    color: Colors.orange,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'ID: $id',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: active ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    active ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: active
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Permissions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // ORDERS
            _permissionTile(
              title: 'Manage Orders',
              subtitle: 'View and manage customer orders',
              icon: Icons.shopping_cart,
              value: canManageOrders,
              onChanged: (value) {
                _updatePermission(documentId, 'canManageOrders', value);
              },
            ),

            // PRODUCTS
            _permissionTile(
              title: 'Manage Products',
              subtitle: 'Add, edit and remove products',
              icon: Icons.restaurant_menu,
              value: canManageProducts,
              onChanged: (value) {
                _updatePermission(documentId, 'canManageProducts', value);
              },
            ),

            // USERS
            _permissionTile(
              title: 'Manage Users',
              subtitle: 'View and manage customers',
              icon: Icons.people,
              value: canManageUsers,
              onChanged: (value) {
                _updatePermission(documentId, 'canManageUsers', value);
              },
            ),

            // COMPLAINTS
            _permissionTile(
              title: 'View Complaints',
              subtitle: 'View and handle customer complaints',
              icon: Icons.report_problem,
              value: canViewComplaints,
              onChanged: (value) {
                _updatePermission(documentId, 'canViewComplaints', value);
              },
            ),

            const SizedBox(height: 8),

            // EDIT ALL BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _openEditPermissions(context, documentId, data);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Permissions'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permissionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: value ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),

      child: SwitchListTile(
        value: value,
        onChanged: onChanged,

        secondary: Icon(
          icon,
          color: value ? Colors.green.shade700 : Colors.grey.shade600,
        ),

        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Future<void> _updatePermission(
    String documentId,
    String permission,
    bool value,
  ) async {
    try {
      await _firestore.collection('Admin').doc(documentId).update({
        permission: value,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? '$permission enabled' : '$permission disabled'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update permission: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openEditPermissions(
    BuildContext context,
    String documentId,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return EditPermissionsDialog(documentId: documentId, data: data);
      },
    );
  }
}

// ============================================================
// EDIT PERMISSIONS DIALOG
// ============================================================

class EditPermissionsDialog extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> data;

  const EditPermissionsDialog({
    super.key,
    required this.documentId,
    required this.data,
  });

  @override
  State<EditPermissionsDialog> createState() => _EditPermissionsDialogState();
}

class _EditPermissionsDialogState extends State<EditPermissionsDialog> {
  late bool canManageOrders;
  late bool canManageProducts;
  late bool canManageUsers;
  late bool canViewComplaints;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    canManageOrders = widget.data['canManageOrders'] ?? false;

    canManageProducts = widget.data['canManageProducts'] ?? false;

    canManageUsers = widget.data['canManageUsers'] ?? false;

    canViewComplaints = widget.data['canViewComplaints'] ?? false;
  }

  Future<void> _savePermissions() async {
    if (saving) return;

    setState(() {
      saving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Admin')
          .doc(widget.documentId)
          .update({
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
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save permissions: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.data['name'] ?? 'Admin';

    return AlertDialog(
      title: Text(
        'Permissions - $name',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Manage Orders'),
              subtitle: const Text('View and manage customer orders'),
              value: canManageOrders,
              onChanged: (value) {
                setState(() {
                  canManageOrders = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Manage Products'),
              subtitle: const Text('Add, edit and remove products'),
              value: canManageProducts,
              onChanged: (value) {
                setState(() {
                  canManageProducts = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Manage Users'),
              subtitle: const Text('View and manage customers'),
              value: canManageUsers,
              onChanged: (value) {
                setState(() {
                  canManageUsers = value;
                });
              },
            ),

            SwitchListTile(
              title: const Text('View Complaints'),
              subtitle: const Text('View and handle complaints'),
              value: canViewComplaints,
              onChanged: (value) {
                setState(() {
                  canViewComplaints = value;
                });
              },
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: saving ? null : _savePermissions,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
