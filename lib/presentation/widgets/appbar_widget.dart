
import 'dart:async';
import 'package:alfred/config/assets_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// State class
class AppBarWidgetState {
  final String currentTime;

  AppBarWidgetState({
    this.currentTime = "",
  });

  AppBarWidgetState copyWith({
    String? currentTime,
  }) {
    return AppBarWidgetState(
      currentTime: currentTime ?? this.currentTime,
    );
  }
}

// StateNotifier
class AppBarWidgetStateNotifier extends StateNotifier<AppBarWidgetState> {
  AppBarWidgetStateNotifier() : super(AppBarWidgetState()) {
    _init();
  }

  Timer? _timer;

  void _init() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final timeString = DateFormat('h:mm').format(now);
    final period = now.hour < 12 ? 'am' : 'pm';
    final dateString = DateFormat('d MMMM').format(now);

    state = state.copyWith(
      currentTime: '$timeString $period, $dateString',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Provider
final appBarWidgetProvider =
StateNotifierProvider<AppBarWidgetStateNotifier, AppBarWidgetState>(
      (ref) => AppBarWidgetStateNotifier(),
);

// Widget
class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = Size.fromHeight(40.h); // Scaled height

  AppBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appBarWidgetProvider);
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
                    child: Text(
                      state.currentTime,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
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
                      '92%', // TODO: Replace with dynamic battery value
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





