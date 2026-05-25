import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UserNameWidget extends StatelessWidget {
  final String text;
  const UserNameWidget({super.key,required this.text});

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
            TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
