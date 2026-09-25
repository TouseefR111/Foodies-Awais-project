import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sizer/sizer.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  // ============================================================
  // SPICE LABEL
  // ============================================================

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

  // ============================================================
  // OIL LABEL
  // ============================================================

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

  // ============================================================
  // GPS ADDRESS
  // ============================================================

  final Geocoding _geocoding = Geocoding();

  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        return "${place.street}, "
            "${place.locality}, "
            "${place.administrativeArea}, "
            "${place.country}";
      }
    } catch (e) {
      debugPrint("Failed to get GPS address: $e");
    }

    return "GPS address not available";
  }

  // ============================================================
  // ORDER STREAM
  // ============================================================

  Stream<QuerySnapshot> orderStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // ============================================================
  // UPDATE ORDER STATUS
  // ============================================================

  Future<void> updateOrderStatus(String orderId, String currentStatus) async {
    if (currentStatus == 'Cancelled') {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order already cancelled')));

      return;
    }

    try {
      String newStatus;

      if (currentStatus == 'Pending') {
        newStatus = 'On the Way';
      } else if (currentStatus == 'On the Way' || currentStatus == 'On a way') {
        newStatus = 'Delivered';
      } else {
        newStatus = currentStatus;
      }

      if (newStatus != currentStatus) {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({'status': newStatus});

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // DELETE ORDER
  // ============================================================

  Future<void> deleteOrder(String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text('Remove Order'),

        content: const Text(
          'Are you sure you want to remove this order? '
          'This action cannot be undone.',
        ),

        actions: [
          // CANCEL
          TextButton(
            onPressed: () => Navigator.pop(context, false),

            child: const Text('Cancel'),
          ),

          // REMOVE
          TextButton(
            onPressed: () => Navigator.pop(context, true),

            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order removed')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to remove order: $e')));
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        title: Text(
          "All Orders",

          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),

        centerTitle: true,

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

        toolbarHeight: 10.h,

        iconTheme: const IconThemeData(color: Colors.black),

        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.elliptical(40, 60),
            bottomLeft: Radius.elliptical(40, 60),
          ),
        ),
      ),

      // ========================================================
      // ORDERS
      // ========================================================
      body: StreamBuilder<QuerySnapshot>(
        stream: orderStream(),

        builder: (context, snapshot) {
          // ====================================================
          // LOADING
          // ====================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ====================================================
          // ERROR
          // ====================================================

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // ====================================================
          // NO ORDERS
          // ====================================================

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found!'));
          }

          // ====================================================
          // ORDERS
          // ====================================================

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,

            itemBuilder: (context, index) {
              // =================================================
              // ORDER DATA
              // =================================================

              final order = orders[index].data() as Map<String, dynamic>;

              final orderId = orders[index].id;

              // =================================================
              // ITEMS
              // =================================================

              final items = order['items'] as List<dynamic>? ?? [];

              // =================================================
              // CUSTOMER INFORMATION
              // =================================================

              final customerName = order['userName'] ?? 'Unknown Customer';

              final phone = order['userContact'] ?? 'No phone number';

              // =================================================
              // CUSTOMER TYPED ADDRESS
              // =================================================

              final customerAddress =
                  order['userAddress'] ?? 'No delivery address provided';

              // =================================================
              // GPS LOCATION
              // =================================================

              final latitude = order['location']?['latitude'];

              final longitude = order['location']?['longitude'];

              // =================================================
              // STATUS
              // =================================================

              final status = order['status'] ?? 'Pending';

              // =================================================
              // CARD
              // =================================================

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),

                elevation: 4,

                child: Padding(
                  padding: EdgeInsets.all(3.w),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // =========================================
                      // ORDER ID + DELETE
                      // =========================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: [
                          Expanded(
                            child: Text(
                              "Order ID: $orderId",

                              style: TextStyle(
                                fontSize: 14.sp,

                                fontWeight: FontWeight.bold,

                                color: Colors.green,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed: () => deleteOrder(orderId),

                            icon: const Icon(Icons.close, color: Colors.red),

                            tooltip: 'Remove order',
                          ),
                        ],
                      ),

                      const Divider(),

                      // =========================================
                      // CUSTOMER NAME
                      // =========================================
                      Text(
                        "Customer: $customerName",

                        style: TextStyle(
                          fontSize: 16.sp,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 0.8.h),

                      // =========================================
                      // PHONE NUMBER
                      // =========================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Icon(Icons.phone, size: 20),

                          SizedBox(width: 2.w),

                          Expanded(
                            child: Text(
                              "Phone: $phone",

                              style: TextStyle(
                                fontSize: 14.sp,

                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 0.8.h),

                      // =========================================
                      // CUSTOMER ADDRESS
                      // =========================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 22,
                            color: Colors.red,
                          ),

                          SizedBox(width: 2.w),

                          Expanded(
                            child: Text(
                              "Delivery Address:\n$customerAddress",

                              style: TextStyle(
                                fontSize: 13.sp,

                                color: Colors.black,

                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 1.h),

                      // =========================================
                      // STATUS
                      // =========================================
                      Text(
                        "Status: $status",

                        style: TextStyle(
                          fontSize: 13.sp,

                          fontWeight: FontWeight.bold,

                          color: status == "Pending"
                              ? Colors.red
                              : status == "On the Way"
                              ? Colors.orange
                              : status == "Cancelled"
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      // =========================================
                      // TOTAL
                      // =========================================
                      Text(
                        "Total Price: ${order['overallTotal']} PKR",

                        style: TextStyle(
                          fontSize: 13.sp,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Divider(),

                      // =========================================
                      // ITEMS
                      // =========================================
                      Text(
                        "Items:",

                        style: TextStyle(
                          fontSize: 14.sp,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 0.5.h),

                      // =========================================
                      // ORDER ITEMS
                      // =========================================
                      ...items.map((item) {
                        final spice = item['spiceLevel'];

                        final oil = item['oilLevel'];

                        String itemText =
                            "${item['itemName']} "
                            "- Quantity: ${item['quantity']} "
                            "- Price: ${item['totalPrice']} PKR";

                        // Spice + Oil
                        if (spice != null && oil != null) {
                          itemText +=
                              "\n(Spice: "
                              "${_getSpiceLabel(spice)}"
                              " | Oil: "
                              "${_getOilLabel(oil)})";
                        }

                        return Padding(
                          padding: EdgeInsets.only(top: 0.5.h),

                          child: Text(
                            itemText,

                            style: TextStyle(fontSize: 13.sp, height: 1.3),
                          ),
                        );
                      }).toList(),

                      SizedBox(height: 1.h),

                      // =========================================
                      // GPS INFORMATION
                      // =========================================
                      if (latitude != null && longitude != null)
                        FutureBuilder<String>(
                          future: getAddressFromCoordinates(
                            (latitude as num).toDouble(),

                            (longitude as num).toDouble(),
                          ),

                          builder: (context, gpsSnapshot) {
                            if (gpsSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                "GPS Address: Loading...",
                                style: TextStyle(color: Colors.grey),
                              );
                            }

                            return Text(
                              "GPS Address: "
                              "${gpsSnapshot.data ?? 'Not available'}",

                              style: TextStyle(
                                fontSize: 13.sp,

                                color: Colors.grey,
                              ),
                            );
                          },
                        ),

                      SizedBox(height: 1.h),

                      // =========================================
                      // UPDATE STATUS BUTTON
                      // =========================================
                      ElevatedButton(
                        onPressed:
                            (status == 'Delivered' || status == 'Cancelled')
                            ? null
                            : () {
                                updateOrderStatus(orderId, status);
                              },

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (status == 'Delivered' || status == 'Cancelled')
                              ? Colors.grey
                              : Colors.green,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),

                          minimumSize: Size(double.infinity, 7.h),
                        ),

                        child: Text(
                          status == 'Delivered'
                              ? "Delivered"
                              : status == 'Cancelled'
                              ? "Cancelled"
                              : status == 'On the Way'
                              ? "Mark as Delivered"
                              : "Put Order On the Way",

                          style: TextStyle(
                            color: Colors.white,

                            fontSize: 14.sp,

                            fontWeight: FontWeight.bold,
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
