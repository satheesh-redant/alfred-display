

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/ros_service.dart';
import '../../states/loading_screen_state.dart';

class LoadingStatusWidget extends StatelessWidget {
  final LoadingScreenState state;

  const LoadingStatusWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Single loading icon
        const SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(),
        ),

        SizedBox(height: 20.h),

        // Dynamic status message
        Text(
          state.statusMessage,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            textStyle: Theme.of(context).textTheme.titleMedium,
            fontSize: 24.sp,
            color: _getStatusColor(),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (state.step) {
      case LoadingStep.connecting:
        return state.connectionStatus == ROSConnectionStatus.connected
            ? Colors.green
            : Colors.orange;

      case LoadingStep.bootChecking:
        final msg = state.statusMessage.toUpperCase();
        if (msg.contains("FAILED")) return Colors.red;
        if (msg.contains("READY")) return Colors.green;
        return Colors.blue;

      case LoadingStep.opsMode:
        return Colors.blue;

      case LoadingStep.navigating:
        return Colors.green;
    }
  }
}
