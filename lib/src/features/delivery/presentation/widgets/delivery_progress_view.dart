import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state/delivery_state.dart';

class DeliveryProgressView extends StatelessWidget {
  final DeliveryState deliveryState;

  const DeliveryProgressView({
    super.key,
    required this.deliveryState,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            deliveryState.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 64.h),
          CircularProgressIndicator(),
          SizedBox(height: 64.h),
          Flexible(
            child: Image.asset(
              "assets/images/alfred_moving.png",
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
