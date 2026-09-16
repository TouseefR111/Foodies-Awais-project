import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/views/my_bottom_nav.dart';
import 'package:sizer/sizer.dart';

import '../controller/shared_pref_helper.dart';

class FoodDetailPage extends StatefulWidget {
  final String image;
  final String itemName;
  final String itemDetail;
  final String itemPrice;

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

class _FoodDetailPageState extends State<FoodDetailPage>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // VARIABLES
  // ============================================================

  int a = 1;
  int total = 0;

  String? id;

  int spiceLevel = 3;
  int oilLevel = 3;

  bool isAddingToCart = false;

  AnimationController? _animationController;

  // ============================================================
  // SPICE LABEL
  // ============================================================

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

  // ============================================================
  // OIL LABEL
  // ============================================================

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

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    total = int.tryParse(widget.itemPrice) ?? 0;

    getShareId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );

      setState(() {});

      _animationController!.forward();
    });
  }

  // ============================================================
  // GET USER ID
  // ============================================================

  Future<void> getShareId() async {
    id = await SharedPrefHelper().getUserId();

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  // ============================================================
  // ANIMATION HELPER
  // ============================================================

  Widget animatedItem({
    required Widget child,
    required double start,
    required double end,
    Offset begin = const Offset(0, 0.20),
  }) {
    if (_animationController == null) {
      return child;
    }

    final Animation<double> animation = CurvedAnimation(
      parent: _animationController!,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  // ============================================================
  // DIET PLAN BOTTOM SHEET
  // ============================================================

  void _showDietPlanBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        int tempSpice = spiceLevel;
        int tempOil = oilLevel;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 6.w,
                right: 6.w,
                top: 1.5.h,
                bottom: MediaQuery.of(context).padding.bottom + 2.h,
              ),

              decoration: const BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 12.w,
                      height: 0.6.h,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  Text(
                    "Customize Your Meal",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xff202020),
                    ),
                  ),

                  SizedBox(height: 0.5.h),

                  Text(
                    "Choose your preferred spice and oil level.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // ==================================================
                  // SPICE
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,

                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.10),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.local_fire_department,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),

                          SizedBox(width: 3.w),

                          Text(
                            "Spice Level",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.6.h,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          _getSpiceLabel(tempSpice),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Slider(
                    value: tempSpice.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.amber.shade100,

                    onChanged: (double value) {
                      setModalState(() {
                        tempSpice = value.toInt();
                      });
                    },
                  ),

                  SizedBox(height: 1.h),

                  // ==================================================
                  // OIL
                  // ==================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10.w,
                            height: 10.w,

                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.opacity_rounded,
                              color: Colors.orange,
                              size: 20,
                            ),
                          ),

                          SizedBox(width: 3.w),

                          Text(
                            "Oil Level",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.6.h,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          _getOilLabel(tempOil),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Slider(
                    value: tempOil.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.amber.shade100,

                    onChanged: (double value) {
                      setModalState(() {
                        tempOil = value.toInt();
                      });
                    },
                  ),

                  SizedBox(height: 2.h),

                  // ==================================================
                  // SAVE
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 6.5.h,

                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          spiceLevel = tempSpice;
                          oilLevel = tempOil;
                        });

                        Navigator.pop(context);
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      child: Text(
                        "Save Preferences",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
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

  // ============================================================
  // ADD TO CART
  // ============================================================

  Future<void> addToCart() async {
    if (id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID not found!")));

      return;
    }

    if (isAddingToCart) return;

    setState(() {
      isAddingToCart = true;
    });

    try {
      await FirebaseFirestore.instance.collection('cart').add({
        "id": id,
        "itemName": widget.itemName,
        "itemDetail": widget.itemDetail,
        "itemPrice": widget.itemPrice,
        "quantity": a,
        "totalPrice": total,
        "image": widget.image,
        "spiceLevel": spiceLevel,
        "oilLevel": oilLevel,
        "addedAt": Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Text(
            "Item added to cart successfully!",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyBottomNav()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add to cart: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isAddingToCart = false;
        });
      }
    }
  }

  // ============================================================
  // QUANTITY BUTTON
  // ============================================================

  Widget quantityButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 11.w,
        height: 5.h,

        decoration: BoxDecoration(
          color: Colors.amberAccent,
          borderRadius: BorderRadius.circular(15),
        ),

        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      body: SafeArea(
        child: Column(
          children: [
            // ====================================================
            // SCROLLABLE CONTENT
            // ====================================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // ==========================================
                    // FOOD IMAGE HEADER
                    // ==========================================
                    Stack(
                      children: [
                        Container(
                          height: 30.h,
                          width: double.infinity,

                          decoration: const BoxDecoration(
                            color: Colors.amberAccent,

                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(45),
                              bottomRight: Radius.circular(45),
                            ),
                          ),

                          child: Padding(
                            padding: EdgeInsets.only(top: 3.h, bottom: 2.h),

                            child: Hero(
                              tag: '${widget.itemName}_${widget.image}',

                              child: Image.network(
                                widget.image,

                                width: double.infinity,
                                height: 32.h,

                                fit: BoxFit.contain,

                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.fastfood_rounded,
                                    size: 90,
                                    color: Colors.grey.shade600,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // ======================================
                        // BACK BUTTON
                        // ======================================
                        Positioned(
                          top: 1.5.h,
                          left: 4.w,

                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },

                            child: Container(
                              width: 11.w,
                              height: 11.w,

                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),

                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18,
                              ),
                            ),
                          ),
                        ),

                        // ======================================
                        // FAVORITE BUTTON
                        // ======================================
                        Positioned(
                          top: 1.5.h,
                          right: 4.w,

                          child: Container(
                            width: 11.w,
                            height: 11.w,

                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 10,
                                ),
                              ],
                            ),

                            child: const Icon(
                              Icons.favorite_border_rounded,
                              size: 21,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // ==========================================
                    // FOOD INFORMATION
                    // ==========================================
                    animatedItem(
                      start: 0.15,
                      end: 0.40,

                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),

                        child: Container(
                          width: double.infinity,

                          padding: EdgeInsets.all(4.w),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(25),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              // Food name + price
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.itemName,

                                      maxLines: 2,

                                      overflow: TextOverflow.ellipsis,

                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xff202020),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 3.w),

                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 1.h,
                                    ),

                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.15),

                                      borderRadius: BorderRadius.circular(15),
                                    ),

                                    child: Text(
                                      "${widget.itemPrice} PKR",

                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.amber.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 1.5.h),

                              // Rating / info row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 20,
                                  ),

                                  SizedBox(width: 1.w),

                                  Text(
                                    "Fresh & Delicious",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  const Spacer(),

                                  Icon(
                                    Icons.restaurant_rounded,
                                    size: 17,
                                    color: Colors.grey.shade500,
                                  ),

                                  SizedBox(width: 1.w),

                                  Text(
                                    "Foodies",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 2.h),

                              // Description heading
                              Text(
                                "About this food",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              SizedBox(height: 0.8.h),

                              Text(
                                widget.itemDetail,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  height: 1.5,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // ==========================================
                    // CUSTOMIZATION
                    // ==========================================
                    animatedItem(
                      start: 0.30,
                      end: 0.55,

                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),

                        child: Container(
                          width: double.infinity,

                          padding: EdgeInsets.all(4.w),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(25),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Column(
                            children: [
                              // Heading
                              Row(
                                children: [
                                  Container(
                                    width: 11.w,
                                    height: 11.w,

                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),

                                    child: const Icon(
                                      Icons.tune_rounded,
                                      color: Colors.amber,
                                    ),
                                  ),

                                  SizedBox(width: 3.w),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        "Customize your meal",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),

                                      SizedBox(height: 0.3.h),

                                      Text(
                                        "Make it just the way you like",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 2.h),

                              // Current preferences
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 1.3.h,
                                ),

                                decoration: BoxDecoration(
                                  color: const Color(0xffF8F8F8),

                                  borderRadius: BorderRadius.circular(15),
                                ),

                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.local_fire_department,
                                          size: 18,
                                          color: Colors.red,
                                        ),

                                        SizedBox(width: 1.5.w),

                                        Text(
                                          _getSpiceLabel(spiceLevel),

                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Container(
                                      width: 1,
                                      height: 3.h,
                                      color: Colors.grey.shade300,
                                    ),

                                    Row(
                                      children: [
                                        Icon(
                                          Icons.opacity_rounded,
                                          size: 18,
                                          color: Colors.orange,
                                        ),

                                        SizedBox(width: 1.5.w),

                                        Text(
                                          _getOilLabel(oilLevel),

                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 1.5.h),

                              // Customize button
                              SizedBox(
                                width: double.infinity,
                                height: 5.5.h,

                                child: OutlinedButton.icon(
                                  onPressed: _showDietPlanBottomSheet,

                                  icon: const Icon(
                                    Icons.restaurant_menu_rounded,
                                    size: 19,
                                  ),

                                  label: Text(
                                    "Change Preferences",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,

                                    side: const BorderSide(
                                      color: Colors.amber,
                                      width: 1.3,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // ==========================================
                    // QUANTITY
                    // ==========================================
                    animatedItem(
                      start: 0.45,
                      end: 0.68,

                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),

                        child: Container(
                          width: double.infinity,

                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.7.h,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(20),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,

                            children: [
                              Text(
                                "Quantity",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              Row(
                                children: [
                                  quantityButton(
                                    icon: Icons.remove,
                                    onTap: () {
                                      if (a > 1) {
                                        setState(() {
                                          a--;
                                          total -=
                                              int.tryParse(widget.itemPrice) ??
                                              0;
                                        });
                                      }
                                    },
                                  ),

                                  SizedBox(width: 4.w),

                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),

                                    transitionBuilder: (child, animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      );
                                    },

                                    child: Text(
                                      "$a",
                                      key: ValueKey(a),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 4.w),

                                  quantityButton(
                                    icon: Icons.add,
                                    onTap: () {
                                      setState(() {
                                        a++;

                                        total +=
                                            int.tryParse(widget.itemPrice) ?? 0;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),

            // ====================================================
            // BOTTOM CART BAR
            // ====================================================
            animatedItem(
              start: 0.60,
              end: 1.00,

              begin: const Offset(0, 0.30),

              child: Container(
                width: double.infinity,

                padding: EdgeInsets.only(
                  left: 5.w,
                  right: 5.w,
                  top: 1.5.h,
                  bottom: MediaQuery.of(context).padding.bottom + 1.5.h,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    // Total
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "Total Amount",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          SizedBox(height: 0.3.h),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),

                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },

                            child: Text(
                              "$total PKR",
                              key: ValueKey(total),

                              style: TextStyle(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Add to cart
                    Expanded(
                      flex: 2,

                      child: SizedBox(
                        height: 6.5.h,

                        child: ElevatedButton(
                          onPressed: isAddingToCart ? null : addToCart,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,

                            disabledBackgroundColor: Colors.grey.shade300,

                            elevation: 3,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          child: isAddingToCart
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,

                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
