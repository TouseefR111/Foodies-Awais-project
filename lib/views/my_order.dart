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

class _MyOrderState extends State<MyOrder> with SingleTickerProviderStateMixin {
  // ============================================================
  // USER DATA
  // ============================================================

  String? userId;
  String? userName;
  String? userContact;

  // ============================================================
  // ANIMATION
  // ============================================================

  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _animationsReady = false;

  // ============================================================
  // GEOCODING
  // ============================================================

  final Geocoding _geocoding = Geocoding();

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Controller MUST be initialized first
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Fade animation
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // Slide animation
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Animations are now ready
    _animationsReady = true;

    // Get user
    getShareId();
  }

  // ============================================================
  // GET USER DATA
  // ============================================================

  Future<void> getShareId() async {
    try {
      final String? id = await SharedPrefHelper().getUserId();

      final String? name = await SharedPrefHelper().getUserName();

      final String? contact = await SharedPrefHelper().getUserContact();

      if (!mounted) return;

      setState(() {
        userId = id;
        userName = name;
        userContact = contact;
      });

      if (_animationsReady &&
          !_animationController.isAnimating &&
          !_animationController.isCompleted) {
        _animationController.forward();
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // SPICE LABEL
  // ============================================================

  String _getSpiceLabel(dynamic level) {
    if (level == null) {
      return "Medium";
    }

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
    if (level == null) {
      return "Medium Oil";
    }

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
  // GET ADDRESS
  // ============================================================

  Future<String> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final List<Placemark> placemarks = await _geocoding
          .placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        final List<String?> parts = [
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ];

        final String address = parts
            .where((part) => part != null && part.trim().isNotEmpty)
            .map((part) => part!.trim())
            .join(", ");

        if (address.isNotEmpty) {
          return address;
        }
      }
    } catch (e) {
      debugPrint("Failed to get address: $e");
    }

    return "Address not available";
  }

  // ============================================================
  // ORDER STREAM
  // ============================================================

  Stream<QuerySnapshot> orderStream() {
    if (userId == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;

      case 'processing':
        return Colors.blue;

      case 'in progress':
        return Colors.blue;

      case 'confirmed':
        return Colors.indigo;

      case 'delivered':
        return Colors.green;

      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      case 'canceled':
        return Colors.red;

      case 'rejected':
        return Colors.redAccent;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // STATUS ICON
  // ============================================================

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.access_time_rounded;

      case 'processing':
        return Icons.restaurant_rounded;

      case 'in progress':
        return Icons.restaurant_rounded;

      case 'confirmed':
        return Icons.check_circle_outline_rounded;

      case 'delivered':
        return Icons.done_all_rounded;

      case 'completed':
        return Icons.done_all_rounded;

      case 'cancelled':
        return Icons.cancel_rounded;

      case 'canceled':
        return Icons.cancel_rounded;

      case 'rejected':
        return Icons.block_rounded;

      default:
        return Icons.info_outline_rounded;
    }
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    final Color color = _getStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: 17, color: color),
          SizedBox(width: 1.w),
          Text(
            status.isEmpty ? "Unknown" : status,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CANCEL ORDER CONFIRMATION
  // ============================================================

  Future<void> confirmCancelOrder(String orderId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_rounded, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Cancel Order?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to cancel "
            "this order?",
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                "No",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Yes, Cancel",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await cancelOrder(orderId);
    }
  }

  // ============================================================
  // CANCEL ORDER
  // ============================================================

  Future<void> cancelOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': 'Cancelled'},
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Row(
            children: [
              Icon(Icons.cancel_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Order cancelled successfully',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text('Failed to cancel order: $e'),
        ),
      );
    }
  }

  // ============================================================
  // CLEAR ORDER HISTORY CONFIRMATION
  // ============================================================

  Future<void> confirmClearHistory() async {
    if (userId == null) {
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Clear Order History?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                ),
              ),
            ],
          ),
          content: const Text(
            "This will remove all your orders "
            "from your order history.\n\n"
            "Your orders will remain available "
            "to the restaurant/admin.",
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                "Keep Orders",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Clear History",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await clearOrderHistory();
    }
  }

  // ============================================================
  // CLEAR ORDER HISTORY
  // ============================================================

  Future<void> clearOrderHistory() async {
    if (userId == null) {
      return;
    }

    try {
      // Get all orders belonging to this user.
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Text("There are no orders to clear."),
          ),
        );

        return;
      }

      // Firestore batch update.
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      for (final document in snapshot.docs) {
        batch.update(document.reference, {'hiddenFromHistory': true});
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Order history cleared successfully",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text("Failed to clear order history: $e"),
        ),
      );
    }
  }

  // ============================================================
  // OPTION CHIP
  // ============================================================

  Widget _optionChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 1.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY ORDERS
  // ============================================================

  Widget _emptyOrders() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 65,
                color: Colors.orange.shade700,
              ),
            ),

            SizedBox(height: 3.h),

            Text(
              "No Orders Yet",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 1.h),

            Text(
              "Your order history will appear here\n"
              "once you place your first order.",
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
  // ORDER CARD
  // ============================================================

  Widget _buildOrderCard(QueryDocumentSnapshot orderDocument, int index) {
    final Map<String, dynamic> order =
        orderDocument.data() as Map<String, dynamic>;

    final List<dynamic> items = order['items'] as List<dynamic>? ?? [];

    final dynamic latitude = order['location']?['latitude'];

    final dynamic longitude = order['location']?['longitude'];

    final String status = order['status']?.toString() ?? '';

    final String orderId = orderDocument.id;

    return FutureBuilder<String>(
      future: latitude != null && longitude != null
          ? getAddressFromCoordinates(
              (latitude as num).toDouble(),
              (longitude as num).toDouble(),
            )
          : Future.value("No location provided"),
      builder: (context, addressSnapshot) {
        final String address = addressSnapshot.data ?? "Loading address...";

        Widget card = Card(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),

          // HIGHER ELEVATION
          elevation: 12,

          shadowColor: Colors.black.withOpacity(0.22),

          surfaceTintColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),

            padding: EdgeInsets.all(4.5.w),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // ORDER HEADER
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFFA000)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.black87,
                        size: 24,
                      ),
                    ),

                    SizedBox(width: 3.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order ID",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          SizedBox(height: 0.4.h),

                          Text(
                            orderId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 1.w),

                    _statusBadge(status),
                  ],
                ),

                SizedBox(height: 2.h),

                const Divider(height: 1),

                SizedBox(height: 1.5.h),

                // ==================================================
                // ADDRESS
                // ==================================================
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.deepOrange,
                        size: 24,
                      ),

                      SizedBox(width: 2.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery Address",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),

                            SizedBox(height: 0.5.h),

                            Text(
                              address,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 1.5.h),

                // ==================================================
                // TOTAL AMOUNT
                // ==================================================
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.payments_rounded,
                        color: Colors.green.shade700,
                        size: 24,
                      ),

                      SizedBox(width: 2.w),

                      Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        "${order['overallTotal'] ?? 0} PKR",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                // ==================================================
                // ORDER ITEMS TITLE
                // ==================================================
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_rounded,
                      size: 22,
                      color: Colors.orange.shade800,
                    ),

                    SizedBox(width: 2.w),

                    Text(
                      "Order Items",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 1.h),

                // ==================================================
                // ITEMS
                // ==================================================
                ...items.map((item) {
                  final dynamic spice = item['spiceLevel'];

                  final dynamic oil = item['oilLevel'];

                  final String itemName =
                      item['itemName']?.toString() ?? "Unknown Item";

                  final String quantity = item['quantity']?.toString() ?? "0";

                  final String price = item['totalPrice']?.toString() ?? "0";

                  return Container(
                    margin: EdgeInsets.only(bottom: 1.h),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                itemName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ),

                            SizedBox(width: 2.w),

                            Text(
                              "$price PKR",
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 0.7.h),

                        Text(
                          "Quantity: $quantity",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        if (spice != null || oil != null) ...[
                          SizedBox(height: 0.8.h),

                          Wrap(
                            spacing: 1.w,
                            runSpacing: 0.5.h,
                            children: [
                              if (spice != null)
                                _optionChip(
                                  icon: Icons.local_fire_department_rounded,
                                  label: "Spice: ${_getSpiceLabel(spice)}",
                                  color: Colors.red,
                                ),

                              if (oil != null)
                                _optionChip(
                                  icon: Icons.water_drop_rounded,
                                  label: "Oil: ${_getOilLabel(oil)}",
                                  color: Colors.blue,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),

                // ==================================================
                // CANCEL BUTTON
                // ==================================================
                if (status.toLowerCase() == "pending") ...[
                  SizedBox(height: 1.h),

                  SizedBox(
                    width: double.infinity,
                    height: 6.5.h,
                    child: ElevatedButton.icon(
                      onPressed: () => confirmCancelOrder(orderId),
                      icon: const Icon(Icons.cancel_outlined, size: 22),
                      label: Text(
                        "Cancel Order",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Colors.red.withOpacity(0.25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],

                // ==================================================
                // CANCELLED MESSAGE
                // ==================================================
                if (status.toLowerCase() == "cancelled" ||
                    status.toLowerCase() == "canceled") ...[
                  SizedBox(height: 1.5.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.withOpacity(0.18)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cancel_rounded,
                          color: Colors.red,
                          size: 24,
                        ),

                        SizedBox(width: 2.w),

                        Expanded(
                          child: Text(
                            "This order has been cancelled.",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );

        // ========================================================
        // SAFE ANIMATION
        // ========================================================

        if (!_animationsReady) {
          return card;
        }

        final double start = (index * 0.08).clamp(0.0, 0.45).toDouble();

        final double end = (start + 0.45).clamp(0.0, 1.0).toDouble();

        final Animation<double> itemAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        );

        return FadeTransition(
          opacity: itemAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(itemAnimation),
            child: card,
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF2),

      // ========================================================
      // APP BAR
      // ========================================================
      appBar: AppBar(
        toolbarHeight: 10.h,
        centerTitle: true,

        title: Text(
          "My Order History",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.black87),

        actions: [
          if (userId != null)
            IconButton(
              tooltip: "Clear Order History",
              onPressed: confirmClearHistory,
              icon: const Icon(
                Icons.delete_sweep_rounded,
                size: 28,
                color: Colors.black87,
              ),
            ),
        ],

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

        elevation: 0,
      ),

      // ========================================================
      // BODY
      // ========================================================
      body: userId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.orange),
                  SizedBox(height: 2.h),
                  Text(
                    "Loading your orders...",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: orderStream(),
              builder: (context, snapshot) {
                // ==================================================
                // WAITING
                // ==================================================

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.orange),
                        SizedBox(height: 2.h),
                        Text(
                          "Loading your orders...",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
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
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 60,
                            color: Colors.redAccent,
                          ),

                          SizedBox(height: 2.h),

                          Text(
                            "Something went wrong",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 1.h),

                          Text(
                            "${snapshot.error}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // ==================================================
                // FILTER HIDDEN ORDERS
                // ==================================================

                final List<QueryDocumentSnapshot> visibleOrders =
                    snapshot.data?.docs.where((document) {
                      final data = document.data() as Map<String, dynamic>;

                      return data['hiddenFromHistory'] != true;
                    }).toList() ??
                    [];

                // ==================================================
                // NO ORDERS
                // ==================================================

                if (visibleOrders.isEmpty) {
                  return _emptyOrders();
                }

                // ==================================================
                // ORDER LIST
                // ==================================================

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(top: 2.h, bottom: 3.h),
                  itemCount: visibleOrders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(visibleOrders[index], index);
                  },
                );
              },
            ),
    );
  }
}
