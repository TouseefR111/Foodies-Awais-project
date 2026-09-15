import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/views/deal_detailpage.dart';
import 'package:sizer/sizer.dart';

class DealWidget extends StatelessWidget {
  const DealWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('deals')
          .where('active', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // No deals
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final deals = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Text(
                "🔥 Special Deals",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 2.h),

            SizedBox(
              height: 24.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: deals.length,
                itemBuilder: (context, index) {
                  final deal = deals[index];

                  final data = deal.data() as Map<String, dynamic>;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DealDetailPage(dealId: deal.id, dealData: data),
                        ),
                      );
                    },
                    child: Container(
                      width: 78.w,
                      margin: EdgeInsets.only(right: 4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Deal Image
                          Expanded(
                            flex: 5,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              child: Image.network(
                                data['imageUrl'],
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Deal Information
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: EdgeInsets.all(3.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['dealName'] ?? 'Special Deal',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  SizedBox(height: 1.h),

                                  Text(
                                    data['description'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  SizedBox(height: 1.h),

                                  Text(
                                    "${data['dealPrice']} PKR",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[800],
                                    ),
                                  ),

                                  Text(
                                    "${data['originalPrice']} PKR",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),

                                  SizedBox(height: 1.h),

                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 0.7.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "View Deal",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
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
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
