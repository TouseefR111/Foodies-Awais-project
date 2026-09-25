import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class DealManageScreen extends StatefulWidget {
  const DealManageScreen({super.key});

  @override
  State<DealManageScreen> createState() => _DealManageScreenState();
}

class _DealManageScreenState extends State<DealManageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 9.h,
        title: const Text('Deal Manage', style: TextStyle(color: Colors.black)),
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('deals')
            .orderBy('createdAt', descending: true)
            .snapshots(),
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
                'No deals found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final deals = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.only(top: 1.h, bottom: 2.h),
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index];

              return DealCard(
                dealId: deal.id,
                dealName: deal['dealName'] ?? '',
                description: deal['description'] ?? '',
                imageUrl: deal['imageUrl'] ?? '',
                originalPrice: (deal['originalPrice'] ?? 0).toDouble(),
                dealPrice: (deal['dealPrice'] ?? 0).toDouble(),
                active: deal['active'] ?? true,
                items: deal['items'] is List
                    ? List<Map<String, dynamic>>.from(
                        (deal['items'] as List).map(
                          (item) => Map<String, dynamic>.from(item),
                        ),
                      )
                    : [],
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// DEAL CARD
// ============================================================

class DealCard extends StatelessWidget {
  final String dealId;
  final String dealName;
  final String description;
  final String imageUrl;
  final double originalPrice;
  final double dealPrice;
  final bool active;
  final List<Map<String, dynamic>> items;

  const DealCard({
    super.key,
    required this.dealId,
    required this.dealName,
    required this.description,
    required this.imageUrl,
    required this.originalPrice,
    required this.dealPrice,
    required this.active,
    required this.items,
  });

  // ==========================================================
  // DELETE DEAL
  // ==========================================================

  Future<void> _deleteDeal(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'Delete Deal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to delete "$dealName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('deals').doc(dealId).delete();

      if (imageUrl.isNotEmpty) {
        try {
          final imageReference = FirebaseStorage.instance.refFromURL(imageUrl);

          await imageReference.delete();
        } catch (e) {
          debugPrint('Could not delete deal image: $e');
        }
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deal deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete deal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // EDIT DEAL
  // ==========================================================

  void _editDeal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return EditDealDialog(
          dealId: dealId,
          dealName: dealName,
          description: description,
          imageUrl: imageUrl,
          dealPrice: dealPrice,
          active: active,
          items: items,
        );
      },
    );
  }

  // ==========================================================
  // BUILD DEAL CARD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final double saving = originalPrice - dealPrice;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 7,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
        child: Column(
          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 20.h,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported, size: 50),
                      ),
              ),
            ),

            SizedBox(height: 2.h),

            // DEAL NAME
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deal Name:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Text(
                    dealName,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(),

            // DESCRIPTION
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 0.8.h),

            Text(description, textAlign: TextAlign.center),

            const Divider(),

            // ORIGINAL PRICE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Original Price:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${originalPrice.toStringAsFixed(0)} PKR',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),

            const Divider(),

            // DEAL PRICE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deal Price:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${dealPrice.toStringAsFixed(0)} PKR',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),

            const Divider(),

            // SAVING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'You Save:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${saving.toStringAsFixed(0)} PKR',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(),

            // STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 0.7.h,
                  ),
                  decoration: BoxDecoration(
                    color: active ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    active ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // EDIT
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.green,
                  child: IconButton(
                    onPressed: () {
                      _editDeal(context);
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                  ),
                ),

                // DELETE
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    onPressed: () {
                      _deleteDeal(context);
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EDIT DEAL DIALOG
// ============================================================

class EditDealDialog extends StatefulWidget {
  final String dealId;
  final String dealName;
  final String description;
  final String imageUrl;
  final double dealPrice;
  final bool active;
  final List<Map<String, dynamic>> items;

  const EditDealDialog({
    super.key,
    required this.dealId,
    required this.dealName,
    required this.description,
    required this.imageUrl,
    required this.dealPrice,
    required this.active,
    required this.items,
  });

  @override
  State<EditDealDialog> createState() => _EditDealDialogState();
}

class _EditDealDialogState extends State<EditDealDialog> {
  late TextEditingController dealNameController;
  late TextEditingController descriptionController;
  late TextEditingController dealPriceController;

  File? selectedImage;

  late bool isActive;

  bool isSaving = false;

  late Map<String, Map<String, dynamic>> selectedProducts;

  @override
  void initState() {
    super.initState();

    dealNameController = TextEditingController(text: widget.dealName);

    descriptionController = TextEditingController(text: widget.description);

    dealPriceController = TextEditingController(
      text: widget.dealPrice.toStringAsFixed(0),
    );

    isActive = widget.active;

    selectedProducts = {};

    // Load previously selected products
    for (final item in widget.items) {
      final String productId = item['productId']?.toString() ?? '';

      if (productId.isEmpty) {
        continue;
      }

      selectedProducts[productId] = {
        'productId': productId,
        'itemName': item['itemName'] ?? '',
        'itemPrice': item['itemPrice'] ?? 0,
        'quantity': item['quantity'] ?? 1,
      };
    }
  }

  @override
  void dispose() {
    dealNameController.dispose();
    descriptionController.dispose();
    dealPriceController.dispose();

    super.dispose();
  }

  // ==========================================================
  // ORIGINAL PRICE
  // ==========================================================

  double get originalPrice {
    double total = 0;

    for (final product in selectedProducts.values) {
      final double price =
          double.tryParse(product['itemPrice'].toString()) ?? 0;

      final int quantity = int.tryParse(product['quantity'].toString()) ?? 1;

      total += price * quantity;
    }

    return total;
  }

  // ==========================================================
  // PICK IMAGE
  // ==========================================================

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    setState(() {
      selectedImage = File(image.path);
    });
  }

  // ==========================================================
  // ADD PRODUCT
  // ==========================================================

  void addProduct(String productId, String itemName, String itemPrice) {
    setState(() {
      if (selectedProducts.containsKey(productId)) {
        selectedProducts[productId]!['quantity']++;
      } else {
        selectedProducts[productId] = {
          'productId': productId,
          'itemName': itemName,
          'itemPrice': itemPrice,
          'quantity': 1,
        };
      }
    });
  }

  // ==========================================================
  // REMOVE PRODUCT
  // ==========================================================

  void removeProduct(String productId) {
    setState(() {
      if (!selectedProducts.containsKey(productId)) {
        return;
      }

      final int quantity = selectedProducts[productId]!['quantity'];

      if (quantity > 1) {
        selectedProducts[productId]!['quantity'] = quantity - 1;
      } else {
        selectedProducts.remove(productId);
      }
    });
  }

  // ==========================================================
  // SAVE EDIT
  // ==========================================================

  Future<void> updateDeal() async {
    if (dealNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter deal name')));
      return;
    }

    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one product')),
      );
      return;
    }

    final double? price = double.tryParse(dealPriceController.text.trim());

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid deal price')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String updatedImageUrl = widget.imageUrl;

      // ------------------------------------------------------
      // Upload new image if selected
      // ------------------------------------------------------

      if (selectedImage != null) {
        final storageReference = FirebaseStorage.instance.ref().child(
          'deal_images/${widget.dealId}.jpg',
        );

        await storageReference.putFile(selectedImage!);

        updatedImageUrl = await storageReference.getDownloadURL();
      }

      // ------------------------------------------------------
      // Prepare items
      // ------------------------------------------------------

      final List<Map<String, dynamic>> updatedItems = selectedProducts.values
          .map((product) {
            return {
              'productId': product['productId'],
              'itemName': product['itemName'],
              'itemPrice': product['itemPrice'],
              'quantity': product['quantity'],
            };
          })
          .toList();

      // ------------------------------------------------------
      // Update Firestore
      // ------------------------------------------------------

      await FirebaseFirestore.instance
          .collection('deals')
          .doc(widget.dealId)
          .update({
            'dealName': dealNameController.text.trim(),

            'description': descriptionController.text.trim(),

            'imageUrl': updatedImageUrl,

            'originalPrice': originalPrice,

            'dealPrice': price,

            'active': isActive,

            'items': updatedItems,

            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deal updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update deal: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        isSaving = false;
      });
    }
  }

  // ==========================================================
  // BUILD EDIT DIALOG
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit Deal',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),

      content: SizedBox(
        width: 90.w,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ------------------------------------------------
              // DEAL NAME
              // ------------------------------------------------
              TextField(
                controller: dealNameController,
                decoration: const InputDecoration(
                  labelText: 'Deal Name',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 1.5.h),

              // ------------------------------------------------
              // DESCRIPTION
              // ------------------------------------------------
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 1.5.h),

              // ------------------------------------------------
              // DEAL PRICE
              // ------------------------------------------------
              TextField(
                controller: dealPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Deal Price',
                  suffixText: 'PKR',
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 1.5.h),

              // ------------------------------------------------
              // ACTIVE SWITCH
              // ------------------------------------------------
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active Deal'),
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
              ),

              SizedBox(height: 1.h),

              // ------------------------------------------------
              // IMAGE
              // ------------------------------------------------
              if (selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    selectedImage!,
                    width: double.infinity,
                    height: 18.h,
                    fit: BoxFit.cover,
                  ),
                )
              else if (widget.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: 18.h,
                    fit: BoxFit.cover,
                  ),
                ),

              SizedBox(height: 1.h),

              // ------------------------------------------------
              // CHANGE IMAGE
              // ------------------------------------------------
              OutlinedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Change Image'),
              ),

              SizedBox(height: 1.5.h),

              // ------------------------------------------------
              // ORIGINAL PRICE
              // ------------------------------------------------
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Original Price: '
                  '${originalPrice.toStringAsFixed(0)} PKR',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 1.5.h),

              // ------------------------------------------------
              // SELECTED PRODUCTS
              // ------------------------------------------------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selected Products',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 1.h),

              if (selectedProducts.isEmpty) const Text('No products selected'),

              ...selectedProducts.values.map((product) {
                final int quantity = product['quantity'];

                return Card(
                  child: ListTile(
                    title: Text(product['itemName']),
                    subtitle: Text('${product['itemPrice']} PKR'),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // MINUS
                        IconButton(
                          onPressed: () {
                            removeProduct(product['productId']);
                          },
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                        ),

                        Text(
                          '$quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        // PLUS
                        IconButton(
                          onPressed: () {
                            addProduct(
                              product['productId'],
                              product['itemName'],
                              product['itemPrice'].toString(),
                            );
                          },
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: 1.h),

              // ------------------------------------------------
              // ADD MORE PRODUCTS
              // ------------------------------------------------
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add More Products',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 1.h),

              SizedBox(
                height: 25.h,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('categoryList')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),

                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No products found'));
                    }

                    final products = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];

                        final String productId = product.id;

                        final String itemName = product['itemName'].toString();

                        final String itemPrice = product['itemPrice']
                            .toString();

                        return ListTile(
                          title: Text(itemName),
                          subtitle: Text('$itemPrice PKR'),
                          trailing: IconButton(
                            onPressed: () {
                              addProduct(productId, itemName, itemPrice);
                            },
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.green,
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
        ),
      ),

      // --------------------------------------------------------
      // ACTIONS
      // --------------------------------------------------------
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),

        ElevatedButton(
          onPressed: isSaving ? null : updateDeal,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrangeAccent,
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
              : const Text('Update', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
