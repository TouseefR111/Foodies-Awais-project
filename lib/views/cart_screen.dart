import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';
import '../controller/shared_pref_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ============================================================
  // USER DATA
  // ============================================================

  String? userId;
  String? userName;
  String? userContact;
  String? userAddress;

  bool isLoadingUser = true;
  bool isPlacingOrder = false;

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController addressController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Load user information first.
    // The cart StreamBuilder will not start until this is complete.
    getShareId();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  // ============================================================
  // GET USER INFORMATION
  // ============================================================

  Future<void> getShareId() async {
    try {
      final String? savedUserId = await SharedPrefHelper().getUserId();

      final String? savedUserName = await SharedPrefHelper().getUserName();

      final String? savedUserContact = await SharedPrefHelper()
          .getUserContact();

      String? savedAddress;

      // ----------------------------------------------------------
      // GET ADDRESS FROM FIRESTORE
      // ----------------------------------------------------------

      if (savedUserId != null && savedUserId.isNotEmpty) {
        try {
          final DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(savedUserId)
              .get();

          if (userDoc.exists) {
            final data = userDoc.data() as Map<String, dynamic>?;

            if (data != null) {
              savedAddress = data['userAddress']?.toString();

              final firestoreContact = data['userContact']?.toString();

              if (firestoreContact != null && firestoreContact.isNotEmpty) {
                // Firestore phone takes priority.
                userContact = firestoreContact;
              }
            }
          }
        } catch (e) {
          debugPrint('Failed to load user details: $e');
        }
      }

      if (!mounted) return;

      setState(() {
        userId = savedUserId;
        userName = savedUserName;

        // Only use saved SharedPreferences contact
        // if Firestore did not provide one.
        userContact ??= savedUserContact;

        userAddress = savedAddress;
        isLoadingUser = false;
      });
    } catch (e) {
      debugPrint('Failed to load user information: $e');

      if (!mounted) return;

      setState(() {
        isLoadingUser = false;
      });
    }
  }

  // ============================================================
  // SPICE LABEL
  // ============================================================

  String _getSpiceLabel(dynamic level) {
    if (level == null) return 'Medium';

    switch (level) {
      case 1:
        return 'Mild';

      case 2:
        return 'Medium';

      case 3:
        return 'Hot';

      case 4:
        return 'Extra Hot';

      case 5:
        return 'Inferno';

      default:
        return 'Medium';
    }
  }

  // ============================================================
  // OIL LABEL
  // ============================================================

  String _getOilLabel(dynamic level) {
    if (level == null) return 'Medium Oil';

    switch (level) {
      case 1:
        return 'No Oil';

      case 2:
        return 'Low Oil';

      case 3:
        return 'Medium Oil';

      case 4:
        return 'High Oil';

      case 5:
        return 'Extra Oil';

      default:
        return 'Medium Oil';
    }
  }

  // ============================================================
  // CALCULATE TOTAL
  // ============================================================

  double calculateTotal(List<QueryDocumentSnapshot> cartItems) {
    double total = 0.0;

    for (final item in cartItems) {
      final data = item.data() as Map<String, dynamic>;

      final dynamic price = data['totalPrice'];

      if (price is num) {
        total += price.toDouble();
      } else {
        total += double.tryParse(price?.toString() ?? '0') ?? 0.0;
      }
    }

    return total;
  }

  // ============================================================
  // DELETE CART ITEM
  // ============================================================

  Future<void> deleteCartItem(String cartItemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(cartItemId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // DELETE CONFIRMATION
  // ============================================================

  Future<void> confirmDeleteCartItem(String cartItemId, String itemName) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Remove Item?',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Remove "$itemName" from your cart?',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Remove',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await deleteCartItem(cartItemId);
    }
  }

  // ============================================================
  // GET CURRENT LOCATION
  // ============================================================

  Future<Position?> _getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission permanently denied. Open app settings.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        await Geolocator.openAppSettings();

        return null;
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (!mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return null;
    }
  }

  // ============================================================
  // SHOW DELIVERY DETAILS DIALOG
  // ============================================================

  Future<void> showOrderDetailsDialog(
    List<QueryDocumentSnapshot> cartItems,
  ) async {
    addressController.text = userAddress ?? '';

    phoneController.text = userContact ?? '';

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          titlePadding: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 1.h),

          contentPadding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),

          actionsPadding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 2.h),

          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 20.sp,
                  color: Colors.black87,
                ),
              ),

              SizedBox(width: 3.w),

              Expanded(
                child: Text(
                  'Delivery Details',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // ADDRESS
                // ==================================================
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                SizedBox(height: 1.h),

                TextField(
                  controller: addressController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'House number, street, area, city',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(
                      Icons.location_on_rounded,
                      color: Colors.orange.shade700,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFFFBF0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.orange.shade700,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // ==================================================
                // PHONE
                // ==================================================
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                SizedBox(height: 1.h),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: '03XXXXXXXXX',
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(
                      Icons.phone_rounded,
                      color: Colors.orange.shade700,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFFFBF0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.orange.shade700,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 1.5.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18.sp,
                        color: Colors.orange.shade800,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Your address and phone number will be saved for your next order.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            Container(
              height: 5.5.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  final address = addressController.text.trim();

                  final phone = phoneController.text.trim();

                  if (address.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your delivery address'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    return;
                  }

                  if (phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your phone number'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    return;
                  }

                  Navigator.pop(dialogContext, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Confirm Order',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await placeOrder(
        cartItems,
        address: addressController.text.trim(),
        phone: phoneController.text.trim(),
      );
    }
  }

  // ============================================================
  // SAVE CUSTOMER DETAILS
  // ============================================================

  Future<void> saveCustomerDetails({
    required String address,
    required String phone,
  }) async {
    if (userId == null || userId!.isEmpty) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'userAddress': address,
        'userContact': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      userAddress = address;
      userContact = phone;
    } catch (e) {
      debugPrint('Failed to save customer details: $e');
    }
  }

  // ============================================================
  // PLACE ORDER
  // ============================================================

  Future<void> placeOrder(
    List<QueryDocumentSnapshot> cartItems, {
    required String address,
    required String phone,
  }) async {
    if (cartItems.isEmpty) return;

    if (userId == null || userId!.isEmpty) {
      return;
    }

    // Calculate total at the exact moment
    // the order is placed.
    final double orderTotal = calculateTotal(cartItems);

    setState(() {
      isPlacingOrder = true;
    });

    try {
      // ========================================================
      // GET LOCATION
      // ========================================================

      final Position? location = await _getCurrentLocation();

      if (location == null) {
        if (mounted) {
          setState(() {
            isPlacingOrder = false;
          });
        }

        return;
      }

      // ========================================================
      // SAVE CUSTOMER DETAILS
      // ========================================================

      await saveCustomerDetails(address: address, phone: phone);

      // ========================================================
      // CREATE ORDER ITEMS
      // ========================================================

      final List<Map<String, dynamic>> orderItems = cartItems.map((item) {
        final data = item.data() as Map<String, dynamic>;

        return {
          'itemName': data['itemName'],
          'quantity': data['quantity'],
          'totalPrice': data['totalPrice'],
          'image': data['image'],

          'isDeal': data['isDeal'] ?? false,

          'dealId': data['dealId'],

          'dealItems': data['dealItems'],

          'spiceLevel': data['spiceLevel'],

          'oilLevel': data['oilLevel'],
        };
      }).toList();

      // ========================================================
      // SAVE ORDER
      // ========================================================

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,

        'userName': userName,

        'userContact': phone,

        'userAddress': address,

        'items': orderItems,

        'overallTotal': orderTotal,

        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },

        'status': 'Pending',

        'timestamp': FieldValue.serverTimestamp(),
      });

      // ========================================================
      // DELETE CART ITEMS
      // ========================================================

      final WriteBatch batch = FirebaseFirestore.instance.batch();

      for (final item in cartItems) {
        batch.delete(item.reference);
      }

      await batch.commit();

      // ========================================================
      // SUCCESS
      // ========================================================

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Order placed successfully! Your cart is now empty.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isPlacingOrder = false;
      });
    }
  }

  // ============================================================
  // CART ITEM CARD
  // ============================================================

  Widget _buildCartItem(QueryDocumentSnapshot document) {
    final Map<String, dynamic> item = document.data() as Map<String, dynamic>;

    final String itemName = item['itemName']?.toString() ?? 'Food Item';

    final String image = item['image']?.toString() ?? '';

    final dynamic quantity = item['quantity'] ?? 1;

    final dynamic totalPrice = item['totalPrice'] ?? 0;

    final bool isDeal = item['isDeal'] == true;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.amber.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==================================================
            // IMAGE
            // ==================================================
            Container(
              width: 23.w,
              height: 23.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: Colors.amber.shade50,
              ),
              clipBehavior: Clip.antiAlias,
              child: image.isNotEmpty
                  ? Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.fastfood_rounded,
                          size: 30.sp,
                          color: Colors.orange.shade700,
                        );
                      },
                    )
                  : Icon(
                      Icons.fastfood_rounded,
                      size: 30.sp,
                      color: Colors.orange.shade700,
                    ),
            ),

            SizedBox(width: 3.w),

            // ==================================================
            // DETAILS
            // ==================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          itemName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ),

                      if (isDeal)
                        Container(
                          margin: EdgeInsets.only(left: 1.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF5252), Color(0xFFD50000)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'DEAL',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Quantity
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 17.sp,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Qty: $quantity',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 0.7.h),

                  // Price
                  Text(
                    'Rs. $totalPrice',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),

                  SizedBox(height: 0.8.h),

                  // Deal / Spice / Oil
                  if (isDeal)
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer_rounded,
                          size: 15.sp,
                          color: Colors.red.shade600,
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            'Special Deal Package',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ],
                    )
                  else if (item['spiceLevel'] != null &&
                      item['oilLevel'] != null)
                    Text(
                      '${_getSpiceLabel(item['spiceLevel'])} • '
                      '${_getOilLabel(item['oilLevel'])}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(width: 2.w),

            // ==================================================
            // DELETE
            // ==================================================
            IconButton(
              tooltip: 'Remove item',
              onPressed: isPlacingOrder
                  ? null
                  : () {
                      confirmDeleteCartItem(document.id, itemName);
                    },
              icon: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red.shade600,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY CART
  // ============================================================

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.25),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 55.sp,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 3.h),

            Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 1.h),

            Text(
              'Add your favorite food and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
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
      backgroundColor: const Color(0xFFFFF9EC),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        toolbarHeight: 9.h,
        centerTitle: true,
        elevation: 0,

        title: Text(
          'My Cart',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: 0.8,
          ),
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

      // ========================================================
      // BODY
      // ========================================================
      body: isLoadingUser
          ? Center(
              child: CircularProgressIndicator(color: Colors.orange.shade700),
            )
          : userId == null || userId!.isEmpty
          ? _buildEmptyCart()
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cart')
                  .where('id', isEqualTo: userId)
                  .snapshots(),

              builder: (context, snapshot) {
                // ==================================================
                // LOADING
                // ==================================================

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange.shade700,
                    ),
                  );
                }

                // ==================================================
                // ERROR
                // ==================================================

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 50.sp,
                            color: Colors.red.shade400,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Unable to load cart',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Please try again.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ==================================================
                // EMPTY
                // ==================================================

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyCart();
                }

                // ==================================================
                // CART ITEMS
                // ==================================================

                final List<QueryDocumentSnapshot> cartItems =
                    snapshot.data!.docs;

                // IMPORTANT:
                // Calculate total locally.
                // Do NOT modify a State variable inside build().
                final double overallTotal = calculateTotal(cartItems);

                // ==================================================
                // MAIN CART UI
                // ==================================================

                return Column(
                  children: [
                    // ==================================================
                    // CART LIST
                    // ==================================================
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(top: 1.5.h, bottom: 1.h),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          return _buildCartItem(cartItems[index]);
                        },
                      ),
                    ),

                    // ==================================================
                    // BOTTOM SUMMARY
                    // ==================================================
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.5.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, -6),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          children: [
                            // ==========================================
                            // TOTAL
                            // ==========================================
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),

                                Text(
                                  'Rs. ${overallTotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 1.5.h),

                            // ==========================================
                            // PLACE ORDER BUTTON
                            // ==========================================
                            Container(
                              width: double.infinity,
                              height: 7.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD54F),
                                    Color(0xFFFFA000),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isPlacingOrder
                                    ? null
                                    : () => showOrderDetailsDialog(cartItems),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isPlacingOrder
                                    ? SizedBox(
                                        width: 23.sp,
                                        height: 23.sp,
                                        child: const CircularProgressIndicator(
                                          color: Colors.black87,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons
                                                .shopping_cart_checkout_rounded,
                                            size: 20.sp,
                                            color: Colors.black87,
                                          ),
                                          SizedBox(width: 2.w),
                                          Text(
                                            'Place Order',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
