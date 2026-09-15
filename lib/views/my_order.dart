import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sizer/sizer.dart';
import '../controller/shared_pref_helper.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  String? userId;
  String? userName;
  String? userContact;

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

  @override
  void initState() {
    super.initState();
    getShareId();
  }

  /// Fetch User ID from Shared Preferences
  Future<void> getShareId() async {
    userId = await SharedPrefHelper().getUserId();
    userName = await SharedPrefHelper().getUserName();
    userContact = await SharedPrefHelper().getUserContact();
    setState(() {});
  }

  /// Convert Latitude and Longitude to Address
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
        return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      }
    } catch (e) {
      debugPrint("Failed to get address: $e");
    }
    return "Address not available";
  }

  /// Stream of Orders from Firestore
  Stream<QuerySnapshot> orderStream() {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  /// Cancel order by updating status
  Future<void> cancelOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': 'Cancelled'},
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order cancelled')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to cancel order: $e')));
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Order History",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
        toolbarHeight: 10.h,
        iconTheme: const IconThemeData(color: Colors.black),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.elliptical(60, 70),
            bottomLeft: Radius.elliptical(60, 70),
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
              final items = order['items'] as List<dynamic>? ?? [];
              final latitude = order['location']?['latitude'];
              final longitude = order['location']?['longitude'];

              return FutureBuilder<String>(
                future: (latitude != null && longitude != null)
                    ? getAddressFromCoordinates(latitude, longitude)
                    : Future.value("No location provided"),
                builder: (context, addressSnapshot) {
                  final address = addressSnapshot.data ?? "Loading address...";
                  final status = order['status'] ?? '';
                  final orderId = orders[index].id;

                  return Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order ID: $orderId",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Divider(),
                          SizedBox(height: 1.h),
                          Text(
                            "Status: $status",
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: status == "Pending"
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "Address: $address",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            "Total Price: ${order['overallTotal']} PKR",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          const Divider(),
                          Text(
                            "Items:",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...items.map((item) {
                            final spice = item['spiceLevel'];
                            final oil = item['oilLevel'];
                            String itemText =
                                "${item['itemName']} - Quantity: ${item['quantity']} - Price: ${item['totalPrice']} PKR";
                            if (spice != null && oil != null) {
                              itemText +=
                                  "\n(Spice: ${_getSpiceLabel(spice)} | Oil: ${_getOilLabel(oil)})";
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 0.5.h),
                              child: Text(
                                itemText,
                                style: TextStyle(fontSize: 10.sp, height: 1.3),
                              ),
                            );
                          }).toList(),
                          if (status == "Pending") ...[
                            SizedBox(height: 2.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => cancelOrder(orderId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Cancel Order",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
