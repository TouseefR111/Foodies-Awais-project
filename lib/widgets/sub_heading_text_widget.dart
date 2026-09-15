import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SubHeadingTextWidget extends StatelessWidget {
  final String text;
  const SubHeadingTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
