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
        toolbarHeight: 8.h,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,

        title: Text(
          'Deal Details',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
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

      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Container(
              height: 30.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      deal['imageUrl']?.toString() ?? '',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;

                        return Container(
                          color: const Color(0xFFFFF8E7),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(
                            color: Color(0xFFFFA000),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFFFF8E7),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fastfood_rounded,
                                size: 55,
                                color: Color(0xFFFFA000),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Image unavailable',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Subtle dark gradient at the bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 90,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.55),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Deal badge
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 17,
                              color: Colors.black87,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'SPECIAL DEAL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Optional savings label
                    Positioned(
                      bottom: 14,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          saving > 0
                              ? 'Save ${saving.toStringAsFixed(0)} PKR'
                              : 'Exclusive Offer',
                          style: const TextStyle(
                            color: Color(0xFF238636),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(
              deal['dealName'],
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
          ),

          // SizedBox(height: 1.h),
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
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(height: 1.h),

          ...items.map((item) {
            return ListTile(
              leading: const Icon(Icons.fastfood, color: Colors.amber),
              title: Text(
                item['itemName'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              trailing: Text(
                "x${item['quantity']}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
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

          SizedBox(height: 2.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: SizedBox(
              height: 6.h,
              child: ElevatedButton(
                onPressed: isAdding ? null : addDealToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                child: isAdding
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Icon(
                            Icons.shopping_cart_rounded,
                            color: Colors.black,
                          ),

                          SizedBox(width: 2.w),

                          Text(
                            "Add to Cart",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
