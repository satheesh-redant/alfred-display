import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RemoveTableButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const RemoveTableButtonWidget({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 24.w,
        height: 24.h,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Icon(
          Icons.remove,
          color: Colors.white,
          size: 16.sp,
        ),
      ),
    );
  }
}
