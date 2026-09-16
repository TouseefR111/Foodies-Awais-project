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
  String? id;
  double overallTotal = 0.0;

  String? userId;
  String? userName;
  String? userContact;
  String? userAddress;

  bool isPlacingOrder = false;

  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // ------------------------------------------------------------
  // SPICE LABEL
  // ------------------------------------------------------------

  String _getSpiceLabel(dynamic level) {
    if (level == null) return "Medium";

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

  // ------------------------------------------------------------
  // OIL LABEL
  // ------------------------------------------------------------

  String _getOilLabel(dynamic level) {
    if (level == null) return "Medium Oil";

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

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    getShareId();
  }

  // ------------------------------------------------------------
  // GET USER INFORMATION
  // ------------------------------------------------------------

  Future<void> getShareId() async {
    userId = await SharedPrefHelper().getUserId();
    userName = await SharedPrefHelper().getUserName();
    userContact = await SharedPrefHelper().getUserContact();

    // Get saved address from Firestore
    if (userId != null && userId!.isNotEmpty) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?;

          if (data != null) {
            userAddress = data['userAddress'];

            // If phone exists in Firestore, use it
            if (data['userContact'] != null &&
                data['userContact'].toString().isNotEmpty) {
              userContact = data['userContact'].toString();
            }
          }
        }
      } catch (e) {
        debugPrint('Failed to load user details: $e');
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ------------------------------------------------------------
  // DELETE CART ITEM
  // ------------------------------------------------------------

  Future<void> deleteCartItem(String cartItemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('cart')
          .doc(cartItemId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removed from cart successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to remove item: $e')));
    }
  }

  // ------------------------------------------------------------
  // CALCULATE TOTAL
  // ------------------------------------------------------------

  double calculateTotal(List<QueryDocumentSnapshot> cartItems) {
    double total = 0.0;

    for (var item in cartItems) {
      final data = item.data() as Map<String, dynamic>;

      total += (data['totalPrice'] as num).toDouble();
    }

    return total;
  }

  // ------------------------------------------------------------
  // GET CURRENT LOCATION
  // ------------------------------------------------------------

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
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
          ),
        );

        await Geolocator.openAppSettings();

        return null;
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );

        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      if (!mounted) return null;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));

      return null;
    }
  }

  // ------------------------------------------------------------
  // SHOW DELIVERY DETAILS DIALOG
  // ------------------------------------------------------------

  Future<void> showOrderDetailsDialog(
    List<QueryDocumentSnapshot> cartItems,
  ) async {
    // Fill fields with saved information
    addressController.text = userAddress ?? '';
    phoneController.text = userContact ?? '';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delivery Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ADDRESS
                TextField(
                  controller: addressController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Delivery Address',
                    hintText: 'House number, street, area, city',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),

                const SizedBox(height: 15),

                // PHONE
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '03XXXXXXXXX',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Your details will be saved for your next order.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          actions: [
            // CANCEL
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

            // CONFIRM
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                final address = addressController.text.trim();

                final phone = phoneController.text.trim();

                if (address.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your delivery address'),
                    ),
                  );

                  return;
                }

                if (phone.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your phone number'),
                    ),
                  );

                  return;
                }

                Navigator.pop(context, true);
              },
              child: const Text(
                'Confirm Order',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
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

  // ------------------------------------------------------------
  // SAVE CUSTOMER DETAILS
  // ------------------------------------------------------------

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

      // Update local variables too
      userAddress = address;
      userContact = phone;
    } catch (e) {
      debugPrint('Failed to save customer details: $e');
    }
  }

  // ------------------------------------------------------------
  // PLACE ORDER
  // ------------------------------------------------------------

  Future<void> placeOrder(
    List<QueryDocumentSnapshot> cartItems, {
    required String address,
    required String phone,
  }) async {
    if (cartItems.isEmpty) return;

    setState(() {
      isPlacingOrder = true;
    });

    try {
      // --------------------------------------------------------
      // GET LOCATION
      // --------------------------------------------------------

      final location = await _getCurrentLocation();

      if (location == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to fetch location. Please try again.'),
            ),
          );
        }

        return;
      }

      // --------------------------------------------------------
      // SAVE CUSTOMER DETAILS
      // --------------------------------------------------------

      await saveCustomerDetails(address: address, phone: phone);

      // --------------------------------------------------------
      // CREATE ORDER ITEMS
      // --------------------------------------------------------

      final orderItems = cartItems.map((item) {
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

      // --------------------------------------------------------
      // SAVE ORDER TO FIRESTORE
      // --------------------------------------------------------

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,

        'userName': userName,

        // Customer phone
        'userContact': phone,

        // Customer delivery address
        'userAddress': address,

        // Products
        'items': orderItems,

        // Total
        'overallTotal': overallTotal,

        // GPS location
        'location': {
          'latitude': location.latitude,
          'longitude': location.longitude,
        },

        // Order status
        'status': 'Pending',

        // Order date/time
        'timestamp': FieldValue.serverTimestamp(),
      });

      // --------------------------------------------------------
      // DELETE CART ITEMS
      // --------------------------------------------------------

      final batch = FirebaseFirestore.instance.batch();

      for (var item in cartItems) {
        batch.delete(item.reference);
      }

      await batch.commit();

      // --------------------------------------------------------
      // SUCCESS
      // --------------------------------------------------------

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Order placed successfully! Your cart is now empty.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isPlacingOrder = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // DISPOSE CONTROLLERS
  // ------------------------------------------------------------

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MY CART',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('id', isEqualTo: userId)
            .snapshots(),

        builder: (context, snapshot) {
          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // ----------------------------------------------------
          // EMPTY CART
          // ----------------------------------------------------

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Your cart is empty!'));
          }

          // ----------------------------------------------------
          // CART ITEMS
          // ----------------------------------------------------

          final cartItems = snapshot.data!.docs;

          overallTotal = calculateTotal(cartItems);

          return Column(
            children: [
              // ------------------------------------------------
              // CART LIST
              // ------------------------------------------------
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,

                  itemBuilder: (context, index) {
                    final item =
                        cartItems[index].data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.amberAccent,

                      margin: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),

                      elevation: 3,

                      child: ListTile(
                        // --------------------------------------
                        // IMAGE
                        // --------------------------------------
                        leading: Image.network(
                          item['image'],
                          width: 15.w,
                          height: 15.w,
                          fit: BoxFit.cover,

                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.fastfood, size: 40);
                          },
                        ),

                        // --------------------------------------
                        // TITLE
                        // --------------------------------------
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['itemName'],
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            // DEAL LABEL
                            if (item['isDeal'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: const Text(
                                  "DEAL",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // --------------------------------------
                        // DETAILS
                        // --------------------------------------
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              'Quantity: ${item['quantity']}',
                              style: const TextStyle(color: Colors.black),
                            ),

                            Text(
                              'Price: ${item['totalPrice']} PKR',
                              style: const TextStyle(color: Colors.black),
                            ),

                            // DEAL
                            if (item['isDeal'] == true)
                              Text(
                                "Special Deal Package",
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            // SPICE/OIL
                            if (item['isDeal'] != true &&
                                item['spiceLevel'] != null &&
                                item['oilLevel'] != null)
                              Text(
                                'Spice: ${_getSpiceLabel(item['spiceLevel'])} | '
                                'Oil: ${_getOilLabel(item['oilLevel'])}',

                                style: const TextStyle(color: Colors.black),
                              ),
                          ],
                        ),

                        // --------------------------------------
                        // DELETE
                        // --------------------------------------
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.black),

                          onPressed: () => deleteCartItem(cartItems[index].id),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ------------------------------------------------
              // TOTAL
              // ------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  Text(
                    "Total :",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "${overallTotal.toStringAsFixed(0)} Pkr",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const Divider(),

              // ------------------------------------------------
              // PLACE ORDER BUTTON
              // ------------------------------------------------
              Padding(
                padding: EdgeInsets.all(3.w),

                child: SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: isPlacingOrder
                        ? null
                        : () => showOrderDetailsDialog(cartItems),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,

                      disabledBackgroundColor: Colors.amberAccent,

                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),

                    child: isPlacingOrder
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            'Place Order',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
