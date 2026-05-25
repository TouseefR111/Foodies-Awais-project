import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BannerImageWidget extends StatelessWidget {
  const BannerImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80.w,
      height: 19.h,
      decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/banner.png"))
      ),
    );
  }
}
