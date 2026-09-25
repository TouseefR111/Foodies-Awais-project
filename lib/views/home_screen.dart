import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:food_delivery_app/views/food_detail_page.dart';
import 'package:food_delivery_app/widgets/banner_image_widget.dart';
import 'package:food_delivery_app/widgets/deal_widget.dart';
import 'package:food_delivery_app/widgets/heading_text_widget.dart';
import 'package:food_delivery_app/widgets/sub_heading_text_widget.dart';
import 'package:food_delivery_app/widgets/user_name_widget.dart';
import 'package:sizer/sizer.dart';

import '../controller/shared_pref_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // VARIABLES
  // ============================================================

  String selectedCategory = 'all';

  String? userName;
  String? userContact;

  AnimationController? _animationController;

  // ============================================================
  // GET USER DATA
  // ============================================================

  Future<void> getShareId() async {
    userName = await SharedPrefHelper().getUserName();
    userContact = await SharedPrefHelper().getUserContact();

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    getShareId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      );

      setState(() {});

      _animationController!.forward();
    });
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
  // REUSABLE ANIMATION
  // ============================================================

  Widget animatedItem({
    required Widget child,
    required double start,
    required double end,
    Offset begin = const Offset(0, 0.20),
    Curve curve = Curves.easeOutBack,
  }) {
    if (_animationController == null) {
      return child;
    }

    final Animation<double> animation = CurvedAnimation(
      parent: _animationController!,
      curve: Interval(start, end, curve: curve),
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
  // PRODUCT SECTION
  // ============================================================

  Widget allWidget() {
    Stream<QuerySnapshot> productStream;

    if (selectedCategory == 'all') {
      productStream = FirebaseFirestore.instance
          .collection('categoryList')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } else {
      productStream = FirebaseFirestore.instance
          .collection('categoryList')
          .where('categoryFood', isEqualTo: selectedCategory)
          .snapshots();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: productStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // ======================================================
        // LOADING
        // ======================================================

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // ======================================================
        // ERROR
        // ======================================================

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // ======================================================
        // EMPTY
        // ======================================================

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(
            height: 150,
            child: Center(
              child: Text(
                'No products found',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        }

        final products = snapshot.data!.docs;

        // ======================================================
        // PRODUCT LIST
        // ======================================================

        return SizedBox(
          height: 31.h,
          child: ListView.builder(
            itemCount: products.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),

            itemBuilder: (context, index) {
              final product = products[index];

              final double start = (index * 0.08).clamp(0.0, 0.55);

              final double end = (start + 0.35).clamp(0.35, 0.95);

              return animatedItem(
                start: start,
                end: end,
                begin: const Offset(0.35, 0),

                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 4.w : 1.w,
                    right: 2.w,
                    bottom: 1.5.h,
                  ),

                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailPage(
                            image: product['imageUrl'],
                            itemName: product['itemName'],
                            itemDetail: product['itemDetail'],
                            itemPrice: product['itemPrice'],
                          ),
                        ),
                      );
                    },

                    child: _ProfessionalFoodCard(
                      imageUrl: product['imageUrl'],
                      itemName: product['itemName'],
                      itemPrice: product['itemPrice'],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // CATEGORY SELECTION
  // ============================================================

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  // ============================================================
  // CATEGORY BUTTON
  // ============================================================

  Widget categoryButton(String imagePath, bool isSelected) {
    return AnimatedScale(
      scale: isSelected ? 1.08 : 1.0,

      duration: const Duration(milliseconds: 250),

      curve: Curves.easeOutBack,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        curve: Curves.easeOut,

        child: Material(
          elevation: isSelected ? 5.0 : 4.0,

          color: isSelected ? Colors.amberAccent : Colors.white,

          borderRadius: BorderRadius.circular(20),

          child: Container(
            width: 16.w,
            height: 8.h,

            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),

            child: Padding(
              padding: const EdgeInsets.all(8.0),

              child: imagePath.endsWith('.svg')
                  ? Image(image: Svg(imagePath), fit: BoxFit.contain)
                  : Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),

      body: ListView(
        physics: const BouncingScrollPhysics(),

        children: [
          // ====================================================
          // USER NAME
          // ====================================================
          animatedItem(
            start: 0.00,
            end: 0.20,

            begin: const Offset(0, -0.30),

            child: UserNameWidget(text: userName?.toUpperCase() ?? "USER"),
          ),

          // ====================================================
          // HEADING
          // ====================================================
          animatedItem(
            start: 0.10,
            end: 0.30,

            child: const HeadingTextWidget(text: "Delicious Food"),
          ),

          // ====================================================
          // SUB HEADING
          // ====================================================
          animatedItem(
            start: 0.18,
            end: 0.35,

            child: const SubHeadingTextWidget(text: "You Get All Food Here."),
          ),

          SizedBox(height: 1.h),

          // ====================================================
          // BANNER
          // ====================================================
          animatedItem(
            start: 0.25,
            end: 0.45,

            begin: const Offset(0, 0.30),

            child: const BannerImageWidget(),
          ),

          SizedBox(height: 3.h),

          // ====================================================
          // CATEGORIES
          // ====================================================
          animatedItem(
            start: 0.35,
            end: 0.65,

            begin: const Offset(0.30, 0),

            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              physics: const BouncingScrollPhysics(),

              child: Padding(
                padding: EdgeInsets.only(left: 3.w, bottom: 2.h, right: 3.w),

                child: Row(
                  children: [
                    // =================================================
                    // BURGER
                    // =================================================
                    Padding(
                      padding: EdgeInsets.only(right: 3.w),

                      child: GestureDetector(
                        onTap: () {
                          selectCategory('Burger');
                        },

                        child: categoryButton(
                          'assets/images/burger.svg',
                          selectedCategory == 'Burger',
                        ),
                      ),
                    ),

                    // =================================================
                    // PIZZA
                    // =================================================
                    Padding(
                      padding: EdgeInsets.only(right: 3.w),

                      child: GestureDetector(
                        onTap: () {
                          selectCategory('Pizza');
                        },

                        child: categoryButton(
                          'assets/images/pizza.svg',
                          selectedCategory == 'Pizza',
                        ),
                      ),
                    ),

                    // =================================================
                    // WINGS
                    // =================================================
                    Padding(
                      padding: EdgeInsets.only(right: 3.w),

                      child: GestureDetector(
                        onTap: () {
                          selectCategory('Wings');
                        },

                        child: categoryButton(
                          'assets/images/wings.svg',
                          selectedCategory == 'Wings',
                        ),
                      ),
                    ),

                    // =================================================
                    // SOUP
                    // =================================================
                    Padding(
                      padding: EdgeInsets.only(right: 3.w),

                      child: GestureDetector(
                        onTap: () {
                          selectCategory('Soup');
                        },

                        child: categoryButton(
                          'assets/images/soup.svg',
                          selectedCategory == 'Soup',
                        ),
                      ),
                    ),

                    // =================================================
                    // SHAWARMA
                    // =================================================
                    Padding(
                      padding: EdgeInsets.only(right: 3.w),

                      child: GestureDetector(
                        onTap: () {
                          selectCategory('Shawarma');
                        },

                        child: categoryButton(
                          'assets/images/shawarma.png',
                          selectedCategory == 'Shawarma',
                        ),
                      ),
                    ),

                    // =================================================
                    // SHAKES
                    // =================================================
                    Padding(
                      padding: EdgeInsets.only(right: 3.w),

                      child: GestureDetector(
                        onTap: () {
                          selectCategory('shakes');
                        },

                        child: categoryButton(
                          'assets/images/shaks.svg',
                          selectedCategory == 'shakes',
                        ),
                      ),
                    ),

                    // =================================================
                    // ALL
                    // =================================================
                    GestureDetector(
                      onTap: () {
                        selectCategory('all');
                      },

                      child: categoryButton(
                        'assets/images/category.svg',
                        selectedCategory == 'all',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ====================================================
          // SPACE
          // ====================================================
          SizedBox(height: 2.h),

          // ====================================================
          // FOOD PRODUCTS
          // ====================================================
          animatedItem(
            start: 0.55,
            end: 0.85,

            begin: const Offset(0.25, 0),

            child: allWidget(),
          ),

          SizedBox(height: 2.h),

          // ====================================================
          // DEAL SECTION
          // ====================================================
          animatedItem(
            start: 0.75,
            end: 1.00,

            begin: const Offset(0, 0.25),

            child: const DealWidget(),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

// =================================================================
// PROFESSIONAL FOOD CARD
// =================================================================

class _ProfessionalFoodCard extends StatefulWidget {
  final String imageUrl;
  final String itemName;
  final dynamic itemPrice;

  const _ProfessionalFoodCard({
    required this.imageUrl,
    required this.itemName,
    required this.itemPrice,
  });

  @override
  State<_ProfessionalFoodCard> createState() => _ProfessionalFoodCardState();
}

class _ProfessionalFoodCardState extends State<_ProfessionalFoodCard> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isPressed ? 0.96 : 1.0,

      duration: const Duration(milliseconds: 120),

      child: Container(
        width: 48.w,
        height: 29.h,

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 7),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ==================================================
            // IMAGE AREA
            // ==================================================
            Container(
              height: 17.h,
              width: double.infinity,

              decoration: const BoxDecoration(
                color: Color(0xffF7F7F7),

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),

              child: Stack(
                children: [
                  // Food image
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(1.5.h),

                      child: Hero(
                        tag: '${widget.itemName}_${widget.imageUrl}',

                        child: Image.network(
                          widget.imageUrl,

                          height: 15.h,
                          width: 38.w,

                          fit: BoxFit.contain,

                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.fastfood_rounded,
                              size: 55,
                              color: Colors.grey.shade400,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Favorite button
                  Positioned(
                    top: 1.h,
                    right: 2.w,

                    child: Container(
                      width: 9.w,
                      height: 9.w,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.favorite_border_rounded,
                        size: 19,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // INFORMATION AREA
            // ==================================================
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 3.w,
                  right: 2.5.w,
                  top: 1.1.h,
                  bottom: 1.h,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // Food name
                    Text(
                      widget.itemName,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,

                        color: const Color(0xff202020),
                      ),
                    ),

                    SizedBox(height: 0.7.h),

                    // Small description
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant_rounded,
                          size: 13,
                          color: Colors.grey.shade500,
                        ),

                        SizedBox(width: 1.w),

                        Text(
                          "Fresh & Delicious",

                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Price + arrow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      crossAxisAlignment: CrossAxisAlignment.center,

                      children: [
                        // Price
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w,
                            vertical: 0.7.h,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.15),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Text(
                            "${widget.itemPrice} PKR",

                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,

                              color: const Color(0xffD18B00),
                            ),
                          ),
                        ),

                        // View button
                        Container(
                          width: 9.w,
                          height: 4.5.h,

                          decoration: BoxDecoration(
                            color: Colors.amberAccent,

                            borderRadius: BorderRadius.circular(13),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: Colors.black87,
                          ),
                        ),
                      ],
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
