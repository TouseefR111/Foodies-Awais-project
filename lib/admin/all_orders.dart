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

  /// Convert Latitude and Longitude to Address
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      debugPrint("Failed to get address: $e");
    }
    return "Address not available";
  }

  /// Stream of Orders from Firestore
  Stream<QuerySnapshot> orderStream() {
    return FirebaseFirestore.instance.collection('orders').snapshots();
  }

  /// Update Order Status in Firestore
  Future<void> updateOrderStatus(String orderId, String currentStatus) async {
    try {
      String newStatus = (currentStatus == 'Pending' || currentStatus == 'On a way')
          ? 'On the Way'
          : 'Delivered';

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Orders",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        toolbarHeight: 10.h,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.elliptical(40, 60),
            bottomLeft: Radius.elliptical(40, 60),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orderStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found!'));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id; // Document ID
              final items = order['items'] as List<dynamic>? ?? [];
              final latitude = order['location']?['latitude'];
              final longitude = order['location']?['longitude'];

              return FutureBuilder<String>(
                future: (latitude != null && longitude != null)
                    ? getAddressFromCoordinates(latitude, longitude)
                    : Future.value("No location provided"),
                builder: (context, addressSnapshot) {
                  final address = addressSnapshot.data ?? "Loading address...";

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order ID: ${order['userId']}",
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          const Divider(),
                          SizedBox(height: 1.h),
                          Text(
                            "Status: ${order['status']}",
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: order['status'] == "Pending" ? Colors.red : Colors.green),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "Address: $address",
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "Total Price: ${order['overallTotal']} PKR",
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                          const Divider(),
                          Text("Items:", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                          ...items.map((item) {
                            final spice = item['spiceLevel'];
                            final oil = item['oilLevel'];
                            String itemText = "${item['itemName']} - Quantity: ${item['quantity']} - Price: ${item['totalPrice']} PKR";
                            if (spice != null && oil != null) {
                              itemText += "\n(Spice: ${_getSpiceLabel(spice)} | Oil: ${_getOilLabel(oil)})";
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 0.5.h),
                              child: Text(
                                itemText,
                                style: TextStyle(fontSize: 10.sp, height: 1.3),
                              ),
                            );
                          }).toList(),
                          SizedBox(height: 2.h),
                          ElevatedButton(
                            onPressed: order['status'] == 'Delivered'
                                ? null // Disable button if status is "Delivered"
                                : () {
                              updateOrderStatus(orderId, order['status']);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: order['status'] == 'Delivered' ? Colors.grey : Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              minimumSize: Size(double.infinity, 7.h),
                            ),
                            child: Text(
                              order['status'] == 'Delivered' ? "Delivered" : "Update Status",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
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
          );
        },
      ),
    );
  }
}
