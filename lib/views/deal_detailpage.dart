import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';

import '../controller/shared_pref_helper.dart';

class DealDetailPage extends StatefulWidget {
  final String dealId;
  final Map<String, dynamic> dealData;

  const DealDetailPage({
    super.key,
    required this.dealId,
    required this.dealData,
  });

  @override
  State<DealDetailPage> createState() => _DealDetailPageState();
}

class _DealDetailPageState extends State<DealDetailPage> {
  bool isAdding = false;

  Future<void> addDealToCart() async {
    setState(() {
      isAdding = true;
    });

    try {
      final userId = await SharedPrefHelper().getUserId();

      final List<dynamic> items = widget.dealData['items'] ?? [];

      await FirebaseFirestore.instance.collection('cart').add({
        'id': userId,
        'itemName': widget.dealData['dealName'],
        'quantity': 1,
        'totalPrice': (widget.dealData['dealPrice'] as num).toDouble(),
        'image': widget.dealData['imageUrl'],

        // Important: identify this as a deal
        'isDeal': true,
        'dealId': widget.dealId,

        // Store the foods included in the deal
        'dealItems': items,

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Deal added to cart successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add deal: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.dealData;

    final List<dynamic> items = deal['items'] ?? [];

    final double originalPrice = (deal['originalPrice'] ?? 0).toDouble();

    final double dealPrice = (deal['dealPrice'] ?? 0).toDouble();

    final double saving = originalPrice - dealPrice;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Deal Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),

      body: ListView(
        padding: EdgeInsets.only(bottom: 3.h),
        children: [
          Image.network(
            deal['imageUrl'],
            height: 28.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          SizedBox(height: 2.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(
              deal['dealName'],
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 1.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(
              deal['description'],
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ),

          SizedBox(height: 3.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(
              "Included Items",
              style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 1.h),

          ...items.map((item) {
            return ListTile(
              leading: const Icon(Icons.fastfood, color: Colors.amber),
              title: Text(
                item['itemName'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                "x${item['quantity']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }),

          const Divider(),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Original Price"),
                    Text(
                      "$originalPrice PKR",
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 1.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Deal Price",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$dealPrice PKR",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[800],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 1.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("You Save"),
                    Text(
                      "$saving PKR",
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

          SizedBox(height: 3.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: SizedBox(
              height: 7.h,
              child: ElevatedButton(
                onPressed: isAdding ? null : addDealToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: isAdding
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        "Add Deal to Cart",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
