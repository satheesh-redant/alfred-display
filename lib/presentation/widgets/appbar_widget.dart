import 'package:alfred/config/assets_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'timer_widget.dart';

class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = Size.fromHeight(40.h);

  AppBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, top: 5.h, bottom: 5.h),
                    child: Image.asset(
                      AlfredConstants.companyLogo,
                      width: 15.w,
                      height: 20.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 27.w, top: 9.h, bottom: 9.h),
                    child: const TimerWidget(),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 18.w),
                    child: InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(
                        AlfredConstants.iconWifi,
                        width: 24.w,
                        height: 24.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 5.w),
                    child: InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(
                        AlfredConstants.iconBattery,
                        width: 24.w,
                        height: 12.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 27.w, top: 9.h, bottom: 9.h),
                    child: Text(
                      '92%',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
