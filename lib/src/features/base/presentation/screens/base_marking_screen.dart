import 'package:alfred/src/core/configs/alfred_constants.dart';
import 'package:alfred/src/shared/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../../../core/configs/ros_constants.dart';
import '../../view_model/base_view_model.dart';
import 'base_marking_complete_screen.dart';
import 'save_starting_point_dialog.dart';
import '../../../../shared/widgets/common_button_widget.dart';

class BasePointMarkingScreen extends ConsumerStatefulWidget {
  const BasePointMarkingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BasePointMarkingScreenState();
}

class _BasePointMarkingScreenState extends ConsumerState<BasePointMarkingScreen> {
  bool _showMarkerScreen = false;
  bool _publishPressed = false; // <-- added

  @override
  Widget build(BuildContext context) {
    ref.listen(
      basePointVMProvider,
          (previous, next) {
        if (_publishPressed && next.message.toUpperCase() == ROSConstants.success) {
          _publishPressed = false; // <-- prevent future auto-navigation
          context.loaderOverlay.hide();
          setState(() {
            _showMarkerScreen = true;
          });
        }
      },
    );

    if (_showMarkerScreen) {
      return BasePointMarkingCompleteScreen(
        onComplete: () => context.go(AlfredConstants.routeTrainingScreen),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AlfredAppBarWidget(),
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
              SizedBox(height: 40.h),
              Expanded(
                child: Center(
                  child: Image.asset(
                    "assets/images/alfred_base_point.png",
                    width: 950.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ButtonWidget(
                text: "I am at the Base Point",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => SaveStartingPointDialog(
                      onConfirmed: () {
                        _publishPressed = true; // <-- added
                        context.loaderOverlay.show();
                        ref.read(basePointVMProvider.notifier).resetBaseLoc();
                      },
                    ),
                  );
                },
                isActive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

