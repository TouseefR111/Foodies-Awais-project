// import 'package:flutter/material.dart';
// import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
// import 'package:sizer/sizer.dart';
//
// import '../controller/database_methods.dart';
// import '../controller/shared_pref_helper.dart';
// import 'food_cart.dart';
// class FoodDetailPage extends StatefulWidget {
//
//   final String image,itemName,itemDetail,itemPrice;
//   const FoodDetailPage({super.key, required this.image, required this.itemName, required this.itemDetail, required this.itemPrice});
//
//   @override
//   State<FoodDetailPage> createState() => _FoodDetailPageState();
// }
//
// class _FoodDetailPageState extends State<FoodDetailPage> {
//   int a = 1;
//   int total = 0;
//
//   String? id;
//
//   getShareId() async{
//     id = await SharedPrefHelper().getUserId();
//     setState(() {
//
//     });
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     total = int.parse(widget.itemPrice);
//     getShareId();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//      return Scaffold(
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           ClipPath(
//             clipper: OvalBottomBorderClipper(),
//             child: Container(
//               height: 40.h,
//               width: MediaQuery.of(context).size.width  ,
//               color: Colors.pink,
//               child: Center(child: Image.network(widget.image, height: 25.h,fit: BoxFit.cover,)),
//             ),
//           ),
//           SizedBox(height: 5.h,),
//
//           Padding(
//             padding: EdgeInsets.only(left: 3.w,right: 3.w),
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.pink),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(13.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 3.w),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(widget.itemName,style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.bold),),
//                           Text("${widget.itemPrice}PKr",style: TextStyle(fontSize: 12.sp,color: Colors.amber,fontWeight: FontWeight.bold),),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 0.9.h,),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 3.w),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.star,color: Colors.amber,size: 20,),
//                           Icon(Icons.star,color: Colors.amber,size: 20,),
//                           const Icon(Icons.star,color: Colors.amber,size: 20,),
//                           const Icon(Icons.star,color: Colors.amber,size: 20,),
//                           const Icon(Icons.star,color: Colors.amber,size: 20,),
//                           SizedBox(width:1.w,),
//                           Text("4.9 Rating",style: TextStyle(fontSize: 10.sp),)
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 2.h,),
//                     const Divider(color: Colors.pink,),
//                     Padding(
//                       padding:EdgeInsets.symmetric(horizontal:3.w),
//                       child: Text("Details",style: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.bold),),
//                     ),
//                     SizedBox(height: 2.h,),
//                     Padding(
//                       padding:EdgeInsets.symmetric(horizontal: 3.w),
//                       child: Text(
//                         textAlign: TextAlign.left,
//                         widget.itemDetail,style: TextStyle(fontSize: 11.sp),
//                       ),
//                     ),
//                     SizedBox(height: 0.9.h,),
//                     const Divider(color: Colors.pink,),
//                     Padding(
//                       padding:EdgeInsets.symmetric(horizontal: 3.w),
//                       child: Row(
//                         children: [
//                           Text("Delivery Time:",style: TextStyle(fontSize: 11.sp)),
//                           SizedBox(width:3.w,),
//                           Text("20mins",style: TextStyle(fontSize: 10.sp)),
//                           SizedBox(width:0.5.w,),
//                           Icon(Icons.alarm,size: 20,)
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 6.h),
//                     Padding(
//                       padding:EdgeInsets.symmetric(horizontal: 3.w),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("Quantity :",style: TextStyle(fontSize: 13.sp,fontWeight: FontWeight.bold)),
//                           SizedBox(width: 3.w,),
//                           GestureDetector(
//                             onTap:(){
//                               if(a>1){
//                                 --a;
//                                 total = total - int.parse(widget.itemPrice);
//                               }
//                               setState(() {
//
//                               });
//
//                             },
//                             child: Container(
//                               width: 8.w,
//                               height: 4.h,
//                               decoration: BoxDecoration(
//                                 color: Colors.pink,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Center(child: Text("-",style: TextStyle(color: Colors.white,fontSize: 18.sp)),),
//                             ),
//                           ),
//                           SizedBox(width: 3.w,),
//                           Text(a.toString()),
//                           SizedBox(width: 3.w,),
//                           GestureDetector(
//                             onTap:(){
//                               ++a;
//                               total = total + int.parse(widget.itemPrice);
//                               setState(() {
//                               });
//                             },
//                             child: Container(
//                               width: 8.w,
//                               height: 4.h,
//                               decoration: BoxDecoration(
//                                 color: Colors.pink,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child:  const Center(child: Text("+",style: TextStyle(color: Colors.white),),),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const Spacer(),
//           Container(
//             width: double.infinity,
//             height: 7.h,
//             decoration: BoxDecoration(
//                 color: Colors.pink,
//                 borderRadius: BorderRadius.circular(10),
//             ),
//             child: Padding(
//               padding:EdgeInsets.symmetric(horizontal: 4.w),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 1.h,),
//                       Text("Total Amount:",style: TextStyle(fontSize: 12.sp,color: Colors.white,fontWeight: FontWeight.bold),),
//                       Text("$total Pkr",style: TextStyle(fontSize: 12.sp,color: Colors.white,fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodCart()));
//                     },
//                     child: Container(
//                       width: 33.w,
//                       height: 5.h,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.white),
//                           borderRadius: BorderRadius.circular(10)
//                       ),
//                       child: Center(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text("Add to Cart",style: TextStyle(color: Colors.white,fontSize: 11.sp),),
//                             SizedBox(width: 2.w,),
//                             const Icon(Icons.add_shopping_cart,color: Colors.white,size: 25,)
//                           ],
//                         ),
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//
//         ],
//       ),
//
//      );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:food_delivery_app/views/my_bottom_nav.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controller/database_methods.dart';
import '../controller/shared_pref_helper.dart';
import 'food_cart.dart';

class FoodDetailPage extends StatefulWidget {
  final String image, itemName, itemDetail, itemPrice;

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

class _FoodDetailPageState extends State<FoodDetailPage> {
  int a = 1;
  int total = 0;
  String? id;

  @override
  void initState() {
    super.initState();
    total = int.parse(widget.itemPrice);
    getShareId();
  }

  getShareId() async {
    id = await SharedPrefHelper().getUserId();
    setState(() {});
  }

  /// Save Item to Cart in Firestore
  Future<void> addToCart() async {
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('cart').add({
        "id":id,
        'itemName': widget.itemName,
        'itemDetail': widget.itemDetail,
        'itemPrice': widget.itemPrice,
        'quantity': a,
        'totalPrice': total,
        'image': widget.image,
        'addedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
            content: Text('Item added to cart successfully!',style: TextStyle(color: Colors.white),)),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyBottomNav()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add to cart: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image Section
          ClipPath(
            clipper: OvalBottomBorderClipper(),
            child: Container(
              height: 40.h,
              width: MediaQuery.of(context).size.width,
              color: Colors.amber,
              child: Center(
                child: Image.network(
                  widget.image,
                  height: 25.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 5.h),

          // Food Details Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.itemName,
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${widget.itemPrice} PKR",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Item Details
                    Text(
                      "Details",
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      widget.itemDetail,
                      style: TextStyle(fontSize: 11.sp),
                    ),
                    SizedBox(height: 2.h),

                    // Quantity Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Quantity:", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                        SizedBox(width: 3.w),
                        GestureDetector(
                          onTap: () {
                            if (a > 1) {
                              setState(() {
                                --a;
                                total -= int.parse(widget.itemPrice);
                              });
                            }
                          },
                          child: Container(
                            width: 8.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text("-", style: TextStyle(color: Colors.black, fontSize: 18.sp,fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(a.toString()),
                        SizedBox(width: 3.w),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              ++a;
                              total += int.parse(widget.itemPrice);
                            });
                          },
                          child: Container(
                            width: 8.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text("+", style: TextStyle(color: Colors.black, fontSize: 18.sp)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),

          // Add to Cart Button
          Container(
            width: double.infinity,
            height: 7.h,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 1.h,),
                      Text("Total Amount:", style: TextStyle(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                      Text("$total PKR", style: TextStyle(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  GestureDetector(
                    onTap: addToCart,
                    child: Container(
                      width: 33.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text("Add to Cart", style: TextStyle(color: Colors.black, fontSize: 11.sp)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
