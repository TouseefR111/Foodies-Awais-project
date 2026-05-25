import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/main.dart';
import 'package:sizer/sizer.dart';

import '../controller/database_methods.dart';
import '../controller/shared_pref_helper.dart';
class FoodCart extends StatefulWidget {
  const FoodCart({super.key});

  @override
  State<FoodCart> createState() => _FoodCartState();
}

class _FoodCartState extends State<FoodCart> {

  String? id;

  getShareId() async{
    id = await SharedPrefHelper().getUserId();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:AppBar(
        title: Text("Food Cart",style: TextStyle(fontWeight: FontWeight.w800,fontSize: 20.sp,color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
         toolbarHeight: 12.h,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(60, 70),bottomRight: Radius.elliptical(60, 70))),
      ) ,
      body: Column(
        children: [
          Padding(
            padding:EdgeInsets.symmetric(horizontal: 5.w),
            child: Container(
              width: double.infinity,
              height: 15.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.pink),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    width: 33.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child:Row(
                      children: [
                        Image.asset("assets/images/pizza.png",height: 15.h,fit: BoxFit.cover,)
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height:2.h,),
                      Text("Crown Crust",style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.bold),),
                      SizedBox(height:1.h,),
                      Row(
                        children: [
                          Text("Quantity:",style: TextStyle(fontSize: 12.sp,fontWeight: FontWeight.bold),),
                          SizedBox(width: 4.w,),
                          Text("4",style: TextStyle(fontSize: 12.sp,),),
                        ],
                      ),
                      SizedBox(height:1.h,),
                      Row(
                        children: [
                          Text("Price:",style: TextStyle(fontSize: 12.sp,fontWeight: FontWeight.bold),),
                          SizedBox(width: 4.w,),
                          Text("599 Pkr",style: TextStyle(fontSize: 12.sp,),),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(width: 10.w,),
                  const Icon(Icons.delete,size: 30,color: Colors.pink,)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
