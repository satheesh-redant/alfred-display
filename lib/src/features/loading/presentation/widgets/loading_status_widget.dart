// //new
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../../../../core/services/ros_service.dart';
// import '../../states/loading_screen_state.dart';
//
// class LoadingStatusWidget extends StatelessWidget {
//   final LoadingScreenState state;
//
//   const LoadingStatusWidget({
//     super.key,
//     required this.state,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Always show loading indicator
//         const CircularProgressIndicator(),
//
//         SizedBox(height: 16.h),
//
//         // Status message
//         Text(
//           state.statusMessage,
//           style: GoogleFonts.inter(
//             textStyle: Theme.of(context).textTheme.titleMedium,
//             fontSize: 24.sp,
//             color: _getStatusColor(),
//           ),
//           textAlign: TextAlign.center,
//         ),
//
//         SizedBox(height: 8.h),
//
//         // Step indicator
//         _buildStepIndicator(context),
//       ],
//     );
//   }
//
//   Color _getStatusColor() {
//     switch (state.step) {
//       case LoadingStep.connecting:
//         return state.connectionStatus == ROSConnectionStatus.connected
//             ? Colors.green
//             : Colors.orange;
//
//       case LoadingStep.bootChecking:
//       // Boot message now comes as string: "READY", "FAILED", progress text
//         final message = state.statusMessage.toUpperCase();
//         if (message.contains("FAILED")) return Colors.red;
//         if (message.contains("READY")) return Colors.green;
//         return Colors.blue;
//
//       case LoadingStep.opsMode:
//         return Colors.blue;
//
//       case LoadingStep.navigating:
//         return Colors.green;
//     }
//   }
//
//   Widget _buildStepIndicator(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildStepDot(LoadingStep.connecting, 'Connection'),
//         _buildStepConnector(),
//         _buildStepDot(LoadingStep.bootChecking, 'System Check'),
//         _buildStepConnector(),
//         _buildStepDot(LoadingStep.opsMode, 'Operation Mode'),
//         _buildStepConnector(),
//         _buildStepDot(LoadingStep.navigating, 'Ready'),
//       ],
//     );
//   }
//
//   Widget _buildStepDot(LoadingStep step, String label) {
//     final isActive = state.step == step;
//     final isCompleted = state.step.index > step.index;
//
//     return Column(
//       children: [
//         Container(
//           width: 12.w,
//           height: 12.h,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: isCompleted
//                 ? Colors.green
//                 : isActive
//                 ? Colors.blue
//                 : Colors.grey,
//           ),
//         ),
//         SizedBox(height: 4.h),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 10.sp,
//             color: isCompleted
//                 ? Colors.green
//                 : isActive
//                 ? Colors.blue
//                 : Colors.grey,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStepConnector() {
//     return Container(
//       width: 30.w,
//       height: 2.h,
//       color: Colors.grey.shade300,
//       margin: EdgeInsets.symmetric(horizontal: 4.w),
//     );
//   }
// }


//loading icon

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
