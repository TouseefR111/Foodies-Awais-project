// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg_provider/flutter_svg_provider.dart';
// import 'package:foodies_app/widgets/banner_image_widget.dart';
// import 'package:foodies_app/widgets/heading_text_widget.dart';
// import 'package:foodies_app/widgets/sub_heading_text_widget.dart';
// import 'package:foodies_app/widgets/user_name_widget.dart';
// import 'package:sizer/sizer.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//
//   bool burger = false, pizza = false, soup = false, wings = false;
//
//   allWidget(){
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance
//           .collection('categoryList')
//           .orderBy('createdAt', descending: true)
//           .snapshots(),
//       builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }
//
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return const Center(child: Text('No products found'));
//         }
//         final products = snapshot.data!.docs;
//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: 4.w),
//           height: MediaQuery.of(context).size.height * 0.3,
//           child: ListView.builder(
//             itemCount: products.length,
//             scrollDirection: Axis.horizontal,
//             shrinkWrap: true,
//             itemBuilder: (context, index) {
//               final product = products[index];
//               return Padding(
//                 padding: EdgeInsets.only(left:3.w,bottom: 2.h),
//                 child: Material(
//                   elevation: 6.0,
//                   borderRadius: BorderRadius.circular(20),
//                   color: Colors.white,
//                   child: Container(
//                     width: 45.w,
//                     height: 30.h,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Image.network(product['imageUrl'],height: 15.h,),
//                         Text(product['itemName'],style: TextStyle(fontSize: 14.sp,fontWeight:FontWeight.bold),),
//                         SizedBox(height: 1.h,),
//                         Text("250 pkr",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12.sp),),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ListView(
//          children: [
//            const UserNameWidget(text: "Hello Touseef"),
//            const HeadingTextWidget(text: "Delicious Food"),
//            const SubHeadingTextWidget(text: "You Get All Food Here."),
//            SizedBox(height: 1.h,),
//            SizedBox(height: 1.h,),
//            const BannerImageWidget(),
//            SizedBox(height: 3.h,),
//            SingleChildScrollView(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 GestureDetector(
//                   onTap:() async{
//                     setState(() {
//                       burger = true;
//                       pizza = false;
//                       soup = false;
//                       wings = false;
//                     });
//                       },
//                   child: Material(
//                     elevation: 7.0,
//                     color: burger ? Colors.grey:Colors.white,
//                     borderRadius: const BorderRadius.all(Radius.circular(25)),
//                     child: Container(
//                       width: 20.w,
//                       height: 10.h,
//                       decoration:
//                       const BoxDecoration(
//                         borderRadius: BorderRadius.all(Radius.circular(25)),
//                       ),
//                       child:const Padding(
//                         padding: EdgeInsets.all(8.0),
//                         child: Image(image: Svg("assets/images/burger.svg",)),
//                       ),
//                       ),
//                     ),
//                 ),
//                 GestureDetector(
//                   onTap:() async{
//                     setState(() {
//                       burger = false;
//                       pizza = true;
//                       soup = false;
//                       wings = false;
//                     });
//                   },
//                   child: Material(
//                     elevation: 7.0,
//                     color: pizza ? Colors.grey:Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       width: 20.w,
//                       height: 10.h,
//                       decoration:
//                       BoxDecoration(borderRadius: BorderRadius.circular(20)
//                       ),
//                       child:Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Image(image: Svg("assets/images/pizza.svg")),
//                       ),
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap:() async{
//                     setState(() {
//                       burger = false;
//                       pizza = false;
//                       soup = false;
//                       wings = true;
//                     });
//                   },
//                   child: Material(
//                     elevation: 7.0,
//                     color: wings ? Colors.grey:Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       width: 20.w,
//                       height: 10.h,
//                       decoration:
//                       BoxDecoration(borderRadius: BorderRadius.circular(20)
//                       ),
//                       child:Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Image(image: Svg("assets/images/wings.svg")),
//                       ),
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap:() async{
//                     setState(() {
//                       burger = false;
//                       pizza = false;
//                       soup = true;
//                       wings = false;
//                     });
//                   },
//                   child: Material(
//                     elevation: 7.0,
//                     color: soup ? Colors.grey:Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       width: 20.w,
//                       height: 10.h,
//                       decoration:
//                       BoxDecoration(borderRadius: BorderRadius.circular(20)
//                       ),
//                       child:Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Image(image: Svg("assets/images/soup.svg")),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//            SizedBox(height: 5.h,),
//           // allData(),
//            allWidget(),
//           SizedBox(height: 2.h,),
//           // Padding(
//           //   padding: const EdgeInsets.only(bottom: 10),
//           //   child: Material(
//           //     elevation: 6.0,
//           //     borderRadius: BorderRadius.circular(20),
//           //     color: Colors.white,
//           //     child: Container(
//           //       width: 90.w,
//           //       height: 18.h,
//           //       decoration: BoxDecoration(
//           //         borderRadius: BorderRadius.circular(20),
//           //       ),
//           //       child: const Row(
//           //         children: [
//           //           Image(image: AssetImage("assets/images/pizza.png")),
//           //           Column(
//           //             mainAxisAlignment: MainAxisAlignment.center,
//           //             children: [
//           //               Text("Pizza | Salad",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
//           //               Text("Special Salad Pizza"),
//           //               Text("50 pkr",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
//           //             ],
//           //           ),
//           //         ],
//           //       ),
//           //     ),
//           //   ),
//           // )
//         ],
//       ),
//
//     );
//   }
// }

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

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'all';

  String? userName;
  String? userContact;

  Future<void> getShareId() async {
    userName = await SharedPrefHelper().getUserName();
    userContact = await SharedPrefHelper().getUserContact();
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getShareId();
  }

  /// Fetch filtered products based on category
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

    return StreamBuilder(
      stream: productStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        final products = snapshot.data!.docs;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          height: MediaQuery.of(context).size.height * 0.3,
          child: ListView.builder(
            itemCount: products.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: EdgeInsets.only(left: 3.w, bottom: 2.h, right: 2.w),
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
                  child: Material(
                    elevation: 8.0,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomRight: Radius.circular(35),
                    ),
                    color: Colors.white,
                    child: Container(
                      width: 44.w,
                      height: 30.h,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 3.h),
                          Text(
                            product['itemName'],
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              product['imageUrl'],
                              height: 13.h,
                            ),
                          ),
                          const Divider(color: Colors.amber),
                          SizedBox(height: 1.h),
                          Text(
                            "${product['itemPrice']} Pkr",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
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

  /// Handle category selection
  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          UserNameWidget(text: userName.toString().toUpperCase()),
          const HeadingTextWidget(text: "Delicious Food"),
          const SubHeadingTextWidget(text: "You Get All Food Here."),
          SizedBox(height: 1.h),
          const BannerImageWidget(),
          SizedBox(height: 3.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: EdgeInsets.only(left: 3.w, bottom: 2.h, right: 3.w),
              child: Row(
                children: [
                  /// Burger Button
                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: GestureDetector(
                      onTap: () => selectCategory('Burger'),
                      child: categoryButton(
                        'assets/images/burger.svg',
                        selectedCategory == 'Burger',
                      ),
                    ),
                  ),

                  /// Pizza Button
                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: GestureDetector(
                      onTap: () => selectCategory('Pizza'),
                      child: categoryButton(
                        'assets/images/pizza.svg',
                        selectedCategory == 'Pizza',
                      ),
                    ),
                  ),

                  /// Wings Button
                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: GestureDetector(
                      onTap: () => selectCategory('Wings'),
                      child: categoryButton(
                        'assets/images/wings.svg',
                        selectedCategory == 'Wings',
                      ),
                    ),
                  ),

                  /// Soup Button
                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: GestureDetector(
                      onTap: () => selectCategory('Soup'),
                      child: categoryButton(
                        'assets/images/soup.svg',
                        selectedCategory == 'Soup',
                      ),
                    ),
                  ),

                  /// Shawarma Button
                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: GestureDetector(
                      onTap: () => selectCategory('Shawarma'),
                      child: categoryButton(
                        'assets/images/shawarma.jpg',
                        selectedCategory == 'Shawarma',
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(right: 3.w),
                    child: GestureDetector(
                      onTap: () => selectCategory('shakes'),
                      child: categoryButton(
                        'assets/images/shaks.svg',
                        selectedCategory == 'shakes',
                      ),
                    ),
                  ),

                  /// All Button
                  GestureDetector(
                    onTap: () => selectCategory('all'),
                    child: categoryButton(
                      'assets/images/category.svg',
                      selectedCategory == 'all',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),
          allWidget(),
          SizedBox(height: 2.h),
          const DealWidget(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  /// Reusable Widget for Category Buttons
  Widget categoryButton(String imagePath, bool isSelected) {
    return Material(
      elevation: 7.0,
      color: isSelected ? Colors.amberAccent : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 16.w,
        height: 8.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image(image: Svg(imagePath)),
        ),
      ),
    );
  }
}
