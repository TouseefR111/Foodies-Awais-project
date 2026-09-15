import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class AddDeal extends StatefulWidget {
  const AddDeal({super.key});

  @override
  State<AddDeal> createState() => _AddDealState();
}

class _AddDealState extends State<AddDeal> {
  final TextEditingController dealNameController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController dealPriceController = TextEditingController();

  File? selectedImage;

  bool isActive = true;
  bool isSaving = false;

  /// Stores selected products
  ///
  /// Example:
  /// {
  ///   productId: abc123,
  ///   itemName: Burger,
  ///   price: 350,
  ///   imageUrl: ...,
  ///   quantity: 2
  /// }
  final Map<String, Map<String, dynamic>> selectedProducts = {};

  /// Pick Deal Image
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to select image: $e")));
    }
  }

  /// Calculate original price
  double get originalPrice {
    double total = 0;

    for (final product in selectedProducts.values) {
      final double price = (product['price'] as num).toDouble();

      final int quantity = product['quantity'] as int;

      total += price * quantity;
    }

    return total;
  }

  /// Calculate saving
  double get saving {
    final double dealPrice =
        double.tryParse(dealPriceController.text.trim()) ?? 0;

    return originalPrice - dealPrice;
  }

  /// Add product
  void addProduct(String productId, Map<String, dynamic> product) {
    setState(() {
      if (selectedProducts.containsKey(productId)) {
        selectedProducts[productId]!['quantity'] =
            (selectedProducts[productId]!['quantity'] as int) + 1;
      } else {
        selectedProducts[productId] = {
          'productId': productId,
          'itemName': product['itemName'] ?? 'Unknown Item',
          'price': double.tryParse(product['itemPrice'].toString()) ?? 0.0,
          'imageUrl': product['imageUrl'] ?? '',
          'quantity': 1,
        };
      }
    });
  }

  /// Remove product
  void removeProduct(String productId) {
    setState(() {
      if (!selectedProducts.containsKey(productId)) {
        return;
      }

      final quantity = selectedProducts[productId]!['quantity'];

      if (quantity > 1) {
        selectedProducts[productId]!['quantity']--;
      } else {
        selectedProducts.remove(productId);
      }
    });
  }

  /// Upload image to Firebase Storage
  Future<String> uploadDealImage() async {
    if (selectedImage == null) {
      throw Exception("Please select a deal image.");
    }

    final String fileName = "deal_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final Reference storageReference = FirebaseStorage.instance
        .ref()
        .child("deal_images")
        .child(fileName);

    await storageReference.putFile(selectedImage!);

    return await storageReference.getDownloadURL();
  }

  /// Save Deal
  Future<void> saveDeal() async {
    if (dealNameController.text.trim().isEmpty) {
      showMessage("Please enter deal name.");
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      showMessage("Please enter deal description.");
      return;
    }

    if (selectedImage == null) {
      showMessage("Please select deal image.");
      return;
    }

    if (selectedProducts.isEmpty) {
      showMessage("Please select at least one food item.");
      return;
    }

    final double? dealPrice = double.tryParse(dealPriceController.text.trim());

    if (dealPrice == null) {
      showMessage("Please enter a valid deal price.");
      return;
    }

    if (dealPrice >= originalPrice) {
      showMessage("Deal price should be lower than original price.");
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      /// Upload image
      final String imageUrl = await uploadDealImage();

      /// Convert selected products to Firestore list
      final List<Map<String, dynamic>> items = selectedProducts.values.map((
        product,
      ) {
        return {
          'productId': product['productId'],
          'itemName': product['itemName'],
          'price': product['price'],
          'quantity': product['quantity'],
        };
      }).toList();

      /// Save deal
      await FirebaseFirestore.instance.collection('deals').add({
        'dealName': dealNameController.text.trim(),

        'description': descriptionController.text.trim(),

        'imageUrl': imageUrl,

        'originalPrice': originalPrice,

        'dealPrice': dealPrice,

        'active': isActive,

        'items': items,

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Deal created successfully!"),
        ),
      );

      /// Clear form
      dealNameController.clear();
      descriptionController.clear();
      dealPriceController.clear();

      setState(() {
        selectedImage = null;
        selectedProducts.clear();
        isActive = true;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to create deal: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    dealNameController.dispose();
    descriptionController.dispose();
    dealPriceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ADD DEAL",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Deal Name
            Text(
              "Deal Name",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
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

            /// Description
            Text(
              "Description",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 1.h),

            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Example: 2 Burgers + Pizza + Drinks",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            /// Deal Image
            Text(
              "Deal Image",
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 1.h),

            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 22.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
                child: selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 50),
                          SizedBox(height: 10),
                          Text("Tap to select deal image"),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),

            SizedBox(height: 3.h),

            /// Products
            Text(
              "Select Food Items",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 1.h),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categoryList')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No products found.");
                }

                final products = snapshot.data!.docs;

                return Column(
                  children: products.map((doc) {
                    final product = doc.data() as Map<String, dynamic>;

                    final productId = doc.id;

                    final bool selected = selectedProducts.containsKey(
                      productId,
                    );

                    final int quantity = selected
                        ? selectedProducts[productId]!['quantity']
                        : 0;

                    return Card(
                      margin: EdgeInsets.only(bottom: 1.h),
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Row(
                          children: [
                            /// Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                product['imageUrl'],
                                width: 18.w,
                                height: 18.w,
                                fit: BoxFit.cover,
                              ),
                            ),

                            SizedBox(width: 3.w),

                            /// Name + Price
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['itemName'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 0.5.h),

                                  Text(
                                    "${product['itemPrice']} PKR",
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Quantity Controls
                            if (!selected)
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.amber,
                                ),
                                onPressed: () => addProduct(productId, product),
                              ),

                            if (selected)
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle),
                                    onPressed: () => removeProduct(productId),
                                  ),

                                  Text(
                                    "$quantity",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle,
                                      color: Colors.amber,
                                    ),
                                    onPressed: () =>
                                        addProduct(productId, product),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            SizedBox(height: 3.h),

            /// Price Summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Original Price"),
                      Text(
                        "${originalPrice.toStringAsFixed(0)} PKR",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  /// Deal Price
                  TextField(
                    controller: dealPriceController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: "Deal Price",
                      suffixText: "PKR",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  SizedBox(height: 1.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("You Save"),
                      Text(
                        "${saving.toStringAsFixed(0)} PKR",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            /// Active switch
            SwitchListTile(
              title: const Text("Deal Active"),
              subtitle: const Text("Show this deal to customers"),
              value: isActive,
              activeColor: Colors.amber,
              onChanged: (value) {
                setState(() {
                  isActive = value;
                });
              },
            ),

            SizedBox(height: 2.h),

            /// Save
            SizedBox(
              width: double.infinity,
              height: 7.h,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveDeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.black)
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
