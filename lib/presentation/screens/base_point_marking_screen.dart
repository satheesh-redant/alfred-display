// import 'package:alfred/src/core/configs/alfred_constants.dart';
// import 'package:alfred/presentation/widgets/appbar_widget.dart';
// import 'package:alfred/presentation/widgets/button_widget.dart';
// import 'package:alfred/view_models/base_point_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:loader_overlay/loader_overlay.dart';
// import '../../src/core/configs/ros_constants.dart';
// import 'base_point_marking_complete_screen.dart';
// import 'save_starting_point_dialog.dart';
//
// class BasePointMarkingScreen extends ConsumerStatefulWidget {
//   const BasePointMarkingScreen({super.key});
//
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _BasePointMarkingScreenState();
// }
//
// class _BasePointMarkingScreenState extends ConsumerState<BasePointMarkingScreen> {
//   bool _showMarkerScreen = false;
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen(
//       basePointVMProvider,
//       (previous, next) {
//           if (next.toUpperCase() == ROSConstants.success) {
//             context.loaderOverlay.hide();
//             setState(() {
//               _showMarkerScreen = true;
//             });
//         }
//       },
//     );
//
//     if (_showMarkerScreen) {
//       return BasePointMarkingCompleteScreen(
//         onComplete: () => context.go(AlfredConstants.routeTrainingScreen),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBarWidget(),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//                 child: Column(
//                   children: [
//               Text(
//                             "Mark Base Point",
//                 textAlign: TextAlign.center,
//                             style: GoogleFonts.inter(
//                   fontSize: 24.sp,
//                   fontWeight: FontWeight.w700,
//                               color: Colors.black,
//                         ),
//                       ),
//               SizedBox(height: 36.h),
//               Text(
//                             "Place Alfred at the Base point to start marking",
//                 textAlign: TextAlign.center,
//                             style: GoogleFonts.inter(
//                   fontSize: 20.sp,
//                   fontWeight: FontWeight.w400,
//                               color: Colors.black,
//                         ),
//                       ),
//               SizedBox(height: 40.h),
//               Expanded(
//                       child: Center(
//                   child: Image.asset(
//                     "assets/images/alfred_base_point.png",
//                     width: 950.w,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.h),
//               ButtonWidget(
//                             text: "I am at the Base Point",
//                             onPressed: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (context) => SaveStartingPointDialog(
//                                   onConfirmed: () {
//                                     ref.context.loaderOverlay.show();
//                                     ref.read(basePointVMProvider.notifier).resetBaseLoc();
//                                   },
//                                 ),
//                               );
//                             },
//                             isActive: true,
//                           ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//   }
// }
//
//
//
//
//
//
//
//
//
//
