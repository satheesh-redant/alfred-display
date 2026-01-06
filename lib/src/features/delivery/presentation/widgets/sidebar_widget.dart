import 'package:alfred/src/shared/providers/system_provider.dart';
import 'package:alfred/src/shared/states/system_state.dart';
import 'package:alfred/src/shared/view_models/system_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/models/operation_mode.dart';
import '../../../../shared/widgets/power_off_dialog.dart';

class SidebarWidget extends ConsumerWidget {
  final SystemState systemState;

  const SidebarWidget({super.key, required this.systemState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemVM = ref.read(systemViewModelProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(left: 0.w, top: 70.h),
      child: SizedBox(
        width: 63.w,
        height: 350.h,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildTrainingButton(context, systemVM),
              SizedBox(height: 40.h),
              _buildSettingsButton(),
              SizedBox(height: 45.h),
              _buildPowerOffButton(context, systemVM),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingButton(BuildContext context, SystemViewModel systemVM) {
    return Column(
      children: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/Edit_icon.svg',
            width: 36.w,
            height: 36.h,
          ),
          onPressed: systemState.isChangingMode
              ? null
              : () => systemVM.changeMode(OperationMode.mapping),
        ),
        Text(
          'Training\nMode',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 12.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildSettingsButton() {
    return Column(
      children: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/images/setting_icon.svg',
            width: 36.w,
            height: 36.h,
          ),
          onPressed: () {},
        ),
        Text("Settings", style: GoogleFonts.nunito(fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildPowerOffButton(BuildContext context, SystemViewModel systemVM) {
    return Column(
      children: [
        IconButton(
          icon: Icon(Icons.power_settings_new_rounded, color: Colors.black, size: 30),
          onPressed: systemState.isPoweringOff
              ? null
              : () => PowerOffDialog.show(context),
        ),
        Text(
          "Power Off",
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontSize: 11.sp),
        ),
      ],
    );
  }
}
