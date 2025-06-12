
import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/presentation/widgets/appbar_widget.dart';
import 'package:alfred/presentation/widgets/button_widget.dart';
import 'package:alfred/view_models/base_point_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'save_starting_point_dialog.dart';

class BasePointMarkingScreen extends ConsumerStatefulWidget {
  const BasePointMarkingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BasePointMarkingScreenState();
}

class _BasePointMarkingScreenState extends ConsumerState<BasePointMarkingScreen> {
  bool _showMarkerScreen = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(
      basePointVMProvider,
          (previous, next) {
        if (next == "Success") {
          context.loaderOverlay.hide();
          ref.read(basePointVMProvider.notifier).removeResetBaseListener();
          setState(() {
            _showMarkerScreen = true;
          });
        }
      },
    );

    if (_showMarkerScreen) {
      return _BasePointMarkerScreen(
        onComplete: () => context.go(AlfredConstants.routeTrainingScreen),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              Text(
                "Mark Base Point",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 36.h),
              Text(
                "Place Alfred at the Base point to start marking",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 60.h),
              Expanded(
                child: Center(
                  child: Image.asset(
                    "assets/images/base_point.png",
                    width: 610.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                //  width: 400.w, // Default to 400 for larger screens, scaled
                child: ButtonWidget(
                  text: "I am at the Base Point",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SaveStartingPointDialog(
                        onConfirmed: () {
                          ref.context.loaderOverlay.show();
                          ref.read(basePointVMProvider.notifier).getResetBaseLocAck();
                          ref.read(basePointVMProvider.notifier).resetBaseLoc();
                        },
                      ),
                    );
                  },
                  isActive: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BasePointMarkerScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const _BasePointMarkerScreen({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) onComplete();
      });
    });

    return Scaffold(
      appBar: AppBarWidget(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
          child: Column(
            children: [
              Text(
                "You are at your Base Point, please move Alfred towards the table to start marking",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/alfred_basepoint_marking.png',
                    width: 868.w,
                    height: 442.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


























