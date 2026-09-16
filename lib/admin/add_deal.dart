import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';

class AddDeal extends StatefulWidget {
  const AddDeal({super.key});

  @override
  State<AddDeal> createState() => _AddDealState();
}

class _AddDealState extends State<AddDeal> {
  // ------------------------------------------------------------
  // Controllers
  // ------------------------------------------------------------

  final TextEditingController dealNameController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();
  final TextEditingController dealPriceController =
      TextEditingController();

  // ------------------------------------------------------------
  // Scroll
  // ------------------------------------------------------------

  final ScrollController scrollController = ScrollController();

  // ------------------------------------------------------------
  // State
  // ------------------------------------------------------------

  File? selectedImage;

  bool isActive = true;
  bool isSaving = false;

  /// Selected products
  ///
  /// {
  ///   productId: {
  ///     productId: abc123,
  ///     itemName: Burger,
  ///     price: 350,
  ///     imageUrl: ...,
  ///     quantity: 2
  ///   }
  /// }
  final Map<String, Map<String, dynamic>> selectedProducts = {};

  // ------------------------------------------------------------
  // Price
  // ------------------------------------------------------------

  double get originalPrice {
    double total = 0;

    for (final product in selectedProducts.values) {
      final double price = (product['price'] as num).toDouble();
      final int quantity = product['quantity'] as int;

      total += price * quantity;
    }

    return total;
  }

  double get dealPrice {
    return double.tryParse(dealPriceController.text.trim()) ?? 0;
  }

  double get saving {
    return originalPrice - dealPrice;
  }

  // ------------------------------------------------------------
  // Pick Image
  // ------------------------------------------------------------

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        selectedImage = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to select image: $e"),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // Add Product
  // ------------------------------------------------------------

  void addProduct(
    String productId,
    Map<String, dynamic> product,
  ) {
    setState(() {
      if (selectedProducts.containsKey(productId)) {
        final int currentQuantity =
            selectedProducts[productId]!['quantity'] as int;

        selectedProducts[productId]!['quantity'] =
            currentQuantity + 1;
      } else {
        selectedProducts[productId] = {
          'productId': productId,
          'itemName': product['itemName'] ?? 'Unknown Item',
          'price': double.tryParse(
                product['itemPrice'].toString(),
              ) ??
              0.0,
          'imageUrl': product['imageUrl'] ?? '',
          'quantity': 1,
        };
      }
    });
  }

  // ------------------------------------------------------------
  // Remove Product
  // ------------------------------------------------------------

  void removeProduct(String productId) {
    setState(() {
      if (!selectedProducts.containsKey(productId)) {
        return;
      }

      final int quantity =
          selectedProducts[productId]!['quantity'] as int;

      if (quantity > 1) {
        selectedProducts[productId]!['quantity'] =
            quantity - 1;
      } else {
        selectedProducts.remove(productId);
      }
    });
  }

  // ------------------------------------------------------------
  // Upload Image
  // ------------------------------------------------------------

  Future<String> uploadDealImage() async {
    if (selectedImage == null) {
      throw Exception("Please select a deal image.");
    }

    final String fileName =
        "deal_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("deal_images")
        .child(fileName);

    await storageReference.putFile(selectedImage!);

    return await storageReference.getDownloadURL();
  }

  // ------------------------------------------------------------
  // Save Deal
  // ------------------------------------------------------------

  Future<void> saveDeal() async {
    // Validate name
    if (dealNameController.text.trim().isEmpty) {
      showMessage("Please enter deal name.");
      return;
    }

    // Validate description
    if (descriptionController.text.trim().isEmpty) {
      showMessage("Please enter deal description.");
      return;
    }

    // Validate image
    if (selectedImage == null) {
      showMessage("Please select deal image.");
      return;
    }

    // Validate products
    if (selectedProducts.isEmpty) {
      showMessage("Please select at least one food item.");
      return;
    }

    // Validate price
    final double? enteredDealPrice =
        double.tryParse(dealPriceController.text.trim());

    if (enteredDealPrice == null) {
      showMessage("Please enter a valid deal price.");
      return;
    }

    if (enteredDealPrice >= originalPrice) {
      showMessage(
        "Deal price should be lower than original price.",
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Upload image
      final String imageUrl = await uploadDealImage();

      // Convert selected products
      final List<Map<String, dynamic>> items =
          selectedProducts.values.map((product) {
        return {
          'productId': product['productId'],
          'itemName': product['itemName'],
          'price': product['price'],
          'quantity': product['quantity'],
        };
      }).toList();

      // Save to Firestore
      await FirebaseFirestore.instance.collection('deals').add({
        'dealName': dealNameController.text.trim(),
        'description': descriptionController.text.trim(),
        'imageUrl': imageUrl,
        'originalPrice': originalPrice,
        'dealPrice': enteredDealPrice,
        'active': isActive,
        'items': items,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Deal created successfully!",
          ),
        ),
      );

      clearForm();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to create deal: $e",
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });
    }
  }

  // ------------------------------------------------------------
  // Clear Form
  // ------------------------------------------------------------

  void clearForm() {
    dealNameController.clear();
    descriptionController.clear();
    dealPriceController.clear();

    setState(() {
      selectedImage = null;
      selectedProducts.clear();
      isActive = true;
    });
  }

  // ------------------------------------------------------------
  // Snackbar
  // ------------------------------------------------------------

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ------------------------------------------------------------
  // Dispose
  // ------------------------------------------------------------

  @override
  void dispose() {
    dealNameController.dispose();
    descriptionController.dispose();
    dealPriceController.dispose();
    scrollController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ADD DEAL",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),

      body: SingleChildScrollView(
        controller: scrollController,
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.all(4.w),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // Deal Name
            // --------------------------------------------------

            Text(
              "Deal Name",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 1.h),

            TextField(
              controller: dealNameController,
              decoration: InputDecoration(
                hintText: "Example: Family Deal",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // --------------------------------------------------
            // Description
            // --------------------------------------------------

            Text(
              "Description",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 1.h),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    "Example: 2 Burgers + Pizza + Drinks",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // --------------------------------------------------
            // Deal Image
            // --------------------------------------------------

            Text(
              "Deal Image",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 1.h),

            GestureDetector(
              onTap: isSaving ? null : pickImage,
              child: Container(
                width: double.infinity,
                height: 22.h,

                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),

                child: selectedImage == null
                    ? const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Tap to select deal image",
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(15),
                        child: Image.file(
                          selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 3.h),

            // --------------------------------------------------
            // Products
            // --------------------------------------------------

            Text(
              "Select Food Items",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 1.h),

            ProductList(
              selectedProducts: selectedProducts,
              onAdd: addProduct,
              onRemove: removeProduct,
            ),

            SizedBox(height: 3.h),

            // --------------------------------------------------
            // Price Summary
            // --------------------------------------------------

            PriceSummary(
              originalPrice: originalPrice,
              dealPriceController: dealPriceController,
              saving: saving,
            ),

            SizedBox(height: 2.h),

            // --------------------------------------------------
            // Active Switch
            // --------------------------------------------------

            SwitchListTile(
              contentPadding: EdgeInsets.zero,

              title: const Text(
                "Deal Active",
              ),

              subtitle: const Text(
                "Show this deal to customers",
              ),

              value: isActive,

              activeColor: Colors.amber,

              onChanged: isSaving
                  ? null
                  : (value) {
                      setState(() {
                        isActive = value;
                      });
                    },
            ),

            SizedBox(height: 2.h),

            // --------------------------------------------------
            // Save Button
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              height: 7.h,

              child: ElevatedButton(
                onPressed:
                    isSaving ? null : saveDeal,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,

                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),

                child: isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 3,
                        ),
                      )
                    : Text(
                        "CREATE DEAL",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT LIST
// ============================================================

class ProductList extends StatelessWidget {
  final Map<String, Map<String, dynamic>> selectedProducts;

  final void Function(
    String productId,
    Map<String, dynamic> product,
  ) onAdd;

  final void Function(String productId) onRemove;

  const ProductList({
    super.key,
    required this.selectedProducts,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('categoryList')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text(
            "Error: ${snapshot.error}",
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return const Text(
            "No products found.",
          );
        }

        final products = snapshot.data!.docs;

        return Column(
          children: products.map((doc) {
            final product =
                doc.data() as Map<String, dynamic>;

            final String productId = doc.id;

            return ProductCard(
              key: ValueKey(productId),

              productId: productId,

              product: product,

              selectedProduct:
                  selectedProducts[productId],

              onAdd: () {
                onAdd(
                  productId,
                  product,
                );
              },

              onRemove: () {
                onRemove(productId);
              },
            );
          }).toList(),
        );
      },
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class ProductCard extends StatelessWidget {
  final String productId;

  final Map<String, dynamic> product;

  final Map<String, dynamic>? selectedProduct;

  final VoidCallback onAdd;

  final VoidCallback onRemove;

  const ProductCard({
    super.key,
    required this.productId,
    required this.product,
    required this.selectedProduct,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected =
        selectedProduct != null;

    final int quantity = selected
        ? selectedProduct!['quantity'] as int
        : 0;

    final String imageUrl =
        product['imageUrl'] ?? '';

    final String itemName =
        product['itemName'] ?? 'Unknown Item';

    final String itemPrice =
        product['itemPrice']?.toString() ?? '0';

    return Card(
      margin: EdgeInsets.only(
        bottom: 1.h,
      ),

      child: Padding(
        padding: EdgeInsets.all(2.w),

        child: Row(
          children: [
            // ------------------------------------------------
            // Image
            // ------------------------------------------------

            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10),

              child: imageUrl.isEmpty
                  ? Container(
                      width: 18.w,
                      height: 18.w,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.fastfood,
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      width: 18.w,
                      height: 18.w,
                      fit: BoxFit.cover,

                      errorBuilder:
                          (
                            context,
                            error,
                            stackTrace,
                          ) {
                        return Container(
                          width: 18.w,
                          height: 18.w,
                          color:
                              Colors.grey.shade300,
                          child: const Icon(
                            Icons.broken_image,
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(width: 3.w),

            // ------------------------------------------------
            // Name + Price
            // ------------------------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    itemName,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 0.5.h),

                  Text(
                    "$itemPrice PKR",

                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // ------------------------------------------------
            // Quantity
            // ------------------------------------------------

            if (!selected)
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.amber,
                ),

                onPressed: onAdd,
              ),

            if (selected)
              Row(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle,
                    ),

                    onPressed: onRemove,
                  ),

                  Text(
                    "$quantity",

                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.amber,
                    ),

                    onPressed: onAdd,
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
// PRICE SUMMARY
// ============================================================

class PriceSummary extends StatefulWidget {
  final double originalPrice;

  final TextEditingController dealPriceController;

  final double saving;

  const PriceSummary({
    super.key,
    required this.originalPrice,
    required this.dealPriceController,
    required this.saving,
  });

  @override
  State<PriceSummary> createState() =>
      _PriceSummaryState();
}

class _PriceSummaryState
    extends State<PriceSummary> {
  double dealPrice = 0;

  @override
  void initState() {
    super.initState();

    dealPrice =
        double.tryParse(
              widget.dealPriceController.text,
            ) ??
            0;
  }

  void updatePrice(String value) {
    setState(() {
      dealPrice =
          double.tryParse(value.trim()) ??
              0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double saving =
        widget.originalPrice - dealPrice;

    return Container(
      width: double.infinity,

      padding: EdgeInsets.all(4.w),

      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color: Colors.amber,
        ),
      ),

      child: Column(
        children: [
          // ------------------------------------------------
          // Original Price
          // ------------------------------------------------

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "Original Price",
              ),

              Text(
                "${widget.originalPrice.toStringAsFixed(0)} PKR",

                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // ------------------------------------------------
          // Deal Price
          // ------------------------------------------------

          TextField(
            controller:
                widget.dealPriceController,

            keyboardType:
                TextInputType.number,

            onChanged: updatePrice,

            decoration: InputDecoration(
              labelText: "Deal Price",
              suffixText: "PKR",

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  10,
                ),
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // ------------------------------------------------
          // Saving
          // ------------------------------------------------

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "You Save",
              ),

              Text(
                "${saving.toStringAsFixed(0)} PKR",

                style: const TextStyle(
                  color: Colors.green,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
