import 'package:flutter/material.dart';
import 'package:food_delivery_app/onboarding_screens/second_screen.dart';
import 'package:sizer/sizer.dart';
class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 12.h,
          ),
          Center(
              child: Image.asset(
                "assets/images/order.jpg",
                width: 80.w,
                height: 30.h,
              )),
          SizedBox(
            height: 8.h,
          ),
          Text(
            textAlign: TextAlign.center,
            "Book Your Order With Us \n With a Cheap Price",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5.h,
          ),
          Text(
            textAlign: TextAlign.center,
            "Enjoy the Delicious \n Fast Food at Your Step",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
          ),
          SizedBox(
            height: 5.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 5.w,
                height: 5.h,
                decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    shape: BoxShape.circle
                ),
              ),
              SizedBox(
                width:1.h,
              ),
              Container(
                width: 5.w,
                height: 5.h,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.deepOrange)
                ),
              ),
              SizedBox(
                width:1.h,
              ),
              Container(
                width: 5.w,
                height: 5.h,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.deepOrange)
                ),
              ),
            ],
          ),
          SizedBox(
            height: 7.h,
          ),
          GestureDetector(
            onTap: (){
             Navigator.push(context, MaterialPageRoute(builder: (context)=> SecondScreen()));
            },
            child: Container(
              width: 80.w,
              height: 7.h,
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(child: Text("Next",style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.bold,color: Colors.white),)),
            ),
          )

        ],
      ),
    );
  }
}


