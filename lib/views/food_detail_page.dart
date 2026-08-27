import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:food_delivery_app/views/my_bottom_nav.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/shared_pref_helper.dart';

class FoodDetailPage extends StatefulWidget {
  final String image, itemName, itemDetail, itemPrice;

  const FoodDetailPage({
    super.key,
    required this.image,
    required this.itemName,
    required this.itemDetail,
    required this.itemPrice,
  });

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  int a = 1;
  int total = 0;
  String? id;
  int spiceLevel = 3; // Default to Medium (3)
  int oilLevel = 3; // Default to Medium (3)

  String _getSpiceLabel(int level) {
    switch (level) {
      case 1:
        return "Mild";
      case 2:
        return "Medium";
      case 3:
        return "Hot";
      case 4:
        return "Extra Hot";
      case 5:
        return "Inferno";
      default:
        return "Medium";
    }
  }

  String _getOilLabel(int level) {
    switch (level) {
      case 1:
        return "No Oil";
      case 2:
        return "Low Oil";
      case 3:
        return "Medium Oil";
      case 4:
        return "High Oil";
      case 5:
        return "Extra Oil";
      default:
        return "Medium Oil";
    }
  }

  void _showDietPlanBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (BuildContext context) {
        int tempSpice = spiceLevel;
        int tempOil = oilLevel;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 12.w,
                      height: 0.6.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Customize Diet Plan",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    "Set your preferred spice and oil levels",
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 3.h),

                  // Spice Level Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Spice Level",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getSpiceLabel(tempSpice),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempSpice.toDouble(),
                    min: 1.0,
                    max: 5.0,
                    divisions: 4,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.amber[100],
                    onChanged: (double value) {
                      setModalState(() {
                        tempSpice = value.toInt();
                      });
                    },
                  ),
                  SizedBox(height: 2.h),

                  // Oil Level Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Oil Level",
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getOilLabel(tempOil),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempOil.toDouble(),
                    min: 1.0,
                    max: 5.0,
                    divisions: 4,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.amber[100],
                    onChanged: (double value) {
                      setModalState(() {
                        tempOil = value.toInt();
                      });
                    },
                  ),
                  SizedBox(height: 4.h),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        spiceLevel = tempSpice;
                        oilLevel = tempOil;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: Size(double.infinity, 6.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      "Save Preferences",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    total = int.parse(widget.itemPrice);
    getShareId();
  }

  getShareId() async {
    id = await SharedPrefHelper().getUserId();
    setState(() {});
  }

  /// Save Item to Cart in Firestore
  Future<void> addToCart() async {
    if (id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found!')));
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('cart').add({
        "id": id,
        'itemName': widget.itemName,
        'itemDetail': widget.itemDetail,
        'itemPrice': widget.itemPrice,
        'quantity': a,
        'totalPrice': total,
        'image': widget.image,
        'spiceLevel': spiceLevel,
        'oilLevel': oilLevel,
        'addedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Item added to cart successfully!',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyBottomNav()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add to cart: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image Section
          ClipPath(
            clipper: OvalBottomBorderClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.40,
              width: MediaQuery.of(context).size.width,
              color: Colors.amber,
              child: Center(
                child: Image.network(
                  widget.image,
                  height: MediaQuery.of(context).size.height * 0.40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 5.h),

          // Food Details Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.itemName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${widget.itemPrice} PKR",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Item Details
                    Text(
                      "Details",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(widget.itemDetail, style: TextStyle(fontSize: 11.sp)),
                    SizedBox(height: 2.h),

                    // Diet Plan Customization
                    const Divider(color: Colors.amberAccent),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Custom Diet Plan",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              "Spice: ${_getSpiceLabel(spiceLevel)} | Oil: ${_getOilLabel(oilLevel)}",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _showDietPlanBottomSheet,
                          icon: const Icon(
                            Icons.restaurant_menu,
                            color: Colors.black,
                            size: 16,
                          ),
                          label: Text(
                            "Diet Plan",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.amberAccent),
                    SizedBox(height: 2.h),

                    // Quantity Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Quantity:",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        GestureDetector(
                          onTap: () {
                            if (a > 1) {
                              setState(() {
                                --a;
                                total -= int.parse(widget.itemPrice);
                              });
                            }
                          },
                          child: Container(
                            width: 8.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "-",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(a.toString()),
                        SizedBox(width: 3.w),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              ++a;
                              total += int.parse(widget.itemPrice);
                            });
                          },
                          child: Container(
                            width: 8.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "+",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),

          // Add to Cart Button
          Container(
            width: double.infinity,
            height: 7.h,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 1.h),
                      Text(
                        "Total Amount:",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$total PKR",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: addToCart,
                    child: Container(
                      width: 33.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "Add to Cart",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
