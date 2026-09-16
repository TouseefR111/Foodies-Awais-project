
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../controller/database_methods.dart';
import '../controller/shared_pref_helper.dart';

class FoodCart extends StatefulWidget {
  const FoodCart({super.key});

  @override
  State<FoodCart> createState() => _FoodCartState();
}

class _FoodCartState extends State<FoodCart> {
  String? userId;

  Stream<QuerySnapshot>? cartStream;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getShareId();
  }

  // Get current logged-in user's ID
  Future<void> getShareId() async {
    try {
      String? id = await SharedPrefHelper().getUserId();

      if (!mounted) return;

      if (id == null || id.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      Stream<QuerySnapshot> stream =
          await DatabaseMethods().getDataFromCartDb(id);

      if (!mounted) return;

      setState(() {
        userId = id;
        cartStream = stream;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading cart: $e"),
        ),
      );
    }
  }

  // Delete cart item
  Future<void> deleteCartItem(String documentId) async {
    try {
      await DatabaseMethods().deleteCart(documentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Item removed from cart"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting item: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Food Cart",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        toolbarHeight: 12.h,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.elliptical(60, 70),
            bottomRight: Radius.elliptical(60, 70),
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : userId == null
              ? const Center(
                  child: Text(
                    "Please login first",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : cartStream == null
                  ? const Center(
                      child: Text(
                        "Unable to load cart",
                      ),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: cartStream,
                      builder: (context, snapshot) {

                        // Loading
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Error
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                "Error loading cart:\n${snapshot.error}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );
                        }

                        // Empty cart
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 15),
                                Text(
                                  "Your cart is empty",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final cartItems =
                            snapshot.data!.docs;

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: 2.h,
                          ),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {

                            final document =
                                cartItems[index];

                            final data = document.data()
                                as Map<String, dynamic>;

                            // Read data from Firestore
                            final String itemName =
                                data["itemName"]?.toString() ??
                                    "Unknown Item";

                            final String quantity =
                                data["quantity"]?.toString() ??
                                    "0";

                            final String price =
                                data["price"]?.toString() ??
                                    "0";

                            final String totalPrice =
                                data["totalPrice"]?.toString() ??
                                    price;

                            final String imageUrl =
                                data["imageUrl"]?.toString() ??
                                    data["image"]?.toString() ??
                                    "";

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 1.h,
                              ),
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  minHeight: 15.h,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.pink,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [

                                    // IMAGE
                                    SizedBox(
                                      width: 33.w,
                                      height: 15.h,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(
                                                15),
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context,
                                                        error,
                                                        stackTrace) {
                                                  return const Icon(
                                                    Icons.fastfood,
                                                    size: 60,
                                                    color:
                                                        Colors.grey,
                                                  );
                                                },
                                              )
                                            : Image.asset(
                                                "assets/images/pizza.png",
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),

                                    SizedBox(width: 3.w),

                                    // INFORMATION
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(
                                          vertical: 1.5.h,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                          children: [

                                            Text(
                                              itemName,
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow
                                                      .ellipsis,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),

                                            SizedBox(height: 1.h),

                                            Row(
                                              children: [
                                                Text(
                                                  "Quantity:",
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                                SizedBox(width: 2.w),
                                                Text(
                                                  quantity,
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 1.h),

                                            Row(
                                              children: [
                                                Text(
                                                  "Price:",
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                  ),
                                                ),
                                                SizedBox(width: 2.w),
                                                Flexible(
                                                  child: Text(
                                                    "$totalPrice Pkr",
                                                    overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                    style: TextStyle(
                                                      fontSize:
                                                          12.sp,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // DELETE
                                    Padding(
                                      padding:
                                          EdgeInsets.only(
                                        right: 2.w,
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          deleteCartItem(
                                            document.id,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 30,
                                          color: Colors.pink,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}

