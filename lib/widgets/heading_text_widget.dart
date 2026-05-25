import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HeadingTextWidget extends StatelessWidget {
  final String text;
  const HeadingTextWidget({super.key,required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style:
            TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
