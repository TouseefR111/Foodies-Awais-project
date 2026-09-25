import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 9.h,
        title: const Text(
          'All Product List',
          style: TextStyle(color: Colors.black),
        ),
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
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('categoryList')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
              return ProductCard(
                productId: product.id,
                itemName: product['itemName'],
                itemPrice: product['itemPrice'],
                itemDetail: product['itemDetail'],
                categoryFood: product['categoryFood'],
                imageUrl: product['imageUrl'],
              );
            },
          );
        },
      ),
    );
  }
}

// Custom Card Widget to Display Each Product
class ProductCard extends StatelessWidget {
  final String productId;
  final String itemName;
  final String itemPrice;
  final String itemDetail;
  final String categoryFood;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.productId,
    required this.itemName,
    required this.itemPrice,
    required this.itemDetail,
    required this.categoryFood,
    required this.imageUrl,
  });

  void _deleteProduct(BuildContext context) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('categoryList')
            .doc(productId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editProduct(BuildContext context) {
    final TextEditingController itemNameController = TextEditingController(
      text: itemName,
    );
    final TextEditingController itemPriceController = TextEditingController(
      text: itemPrice,
    );
    final TextEditingController itemDetailController = TextEditingController(
      text: itemDetail,
    );
    final TextEditingController categoryFoodController = TextEditingController(
      text: categoryFood,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: itemNameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                TextField(
                  controller: itemPriceController,
                  decoration: const InputDecoration(labelText: 'Item Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: itemDetailController,
                  decoration: const InputDecoration(labelText: 'Item Detail'),
                ),
                TextField(
                  controller: categoryFoodController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('categoryList')
                      .doc(productId)
                      .update({
                        'itemName': itemNameController.text,
                        'itemPrice': itemPriceController.text,
                        'itemDetail': itemDetailController.text,
                        'categoryFood': categoryFoodController.text,
                        'updatedAt': FieldValue.serverTimestamp(),
                      });
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Update', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 7.0,
      child: Column(
        children: [
          SizedBox(height: 3.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("Item Name:"),
              Text(
                itemName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [const Text("Item Price:"), Text('$itemPrice Pkr')],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [const Text("Category:"), Text(categoryFood)],
          ),
          const Divider(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(textAlign: TextAlign.center, itemDetail),
          ),
          const Divider(),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.green,
                child: IconButton(
                  onPressed: () => _editProduct(context),
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
              ),
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.red,
                child: IconButton(
                  onPressed: () => _deleteProduct(context),
                  icon: const Icon(Icons.delete, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
