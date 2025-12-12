// import 'package:alfred/src/core/configs/alfred_constants.dart';
// import 'package:alfred/src/core/configs/ros_constants.dart';
// import 'package:alfred/src/core/helpers/routes.dart';
// import 'package:alfred/src/features/routing/route_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:loader_overlay/loader_overlay.dart';
// import 'package:toastification/toastification.dart';
//
// import 'table_grid_button_widget.dart';
// import 'base_point_view_model.dart';
// import 'table_view_model.dart';
// import '../../core/helpers/toast_utils.dart';
// import '../checklist/presentation/widget/buttonwidget.dart';
// import '../loading/providers/loading_providers.dart';
//
//
//
// class RoutingScreen extends ConsumerStatefulWidget {
//   const RoutingScreen({super.key});
//
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _RoutingScreenState();
// }
//
// class _RoutingScreenState extends ConsumerState<RoutingScreen> {
//   int? selectedTable = -1;
//
//   @override
//   void initState() {
//     super.initState();
//     ref.read(tableVMProvider.notifier).requestTableList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen(
//       basePointVMProvider,
//           (previous, next) {
//         if (next.isNotEmpty) {
//           if (next.toUpperCase() == ROSConstants.success) {
//             ref.read(basePointVMProvider.notifier).stopTimer();
//           } else {
//             ref.context.loaderOverlay.hide();
//           }
//         }
//       },
//     );
//
//     ref.listen(
//      // opsVMProvider,
//       operationsServiceProvider,
//           (previous, next) {
//         if (next == 'delivery') {
//           ref.context.loaderOverlay.hide();
//           context.go(AlfredConstants.routeDeliveryMainScreen);
//         }
//       },
//     );
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: EdgeInsets.all(30),
//         child: Column(
//           children: [
//             Expanded(
//               flex: 1,
//               child: Text(
//                 "Select a table and start planning the route",
//                 style: GoogleFonts.inter(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w400,
//                   color: Colors.black,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//               ),
//             ),
//             Expanded(
//                 flex: 5,
//                 child: Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.only(right: 40),
//                   child: ref.watch(tableVMProvider).isEmpty
//                       ? Center(
//                           child: Text(
//                             "No tables marked yet\nPlease mark tables in Training Mode first",
//                             textAlign: TextAlign.center,
//                             style: GoogleFonts.nunito(
//                               fontSize: 16,
//                               color: Colors.grey,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         )
//                       : GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 6,
//                             crossAxisSpacing: 49,
//                             mainAxisSpacing: 26,
//                             childAspectRatio: 138 / 60,
//                           ),
//                           itemCount: ref.watch(tableVMProvider).length,
//                           itemBuilder: (context, index) {
//                             final data = ref.watch(tableVMProvider);
//                             print(data);
//                             final isSelected = selectedTable == data[index];
//                             return Padding(
//                               padding: EdgeInsets.only(
//                                 right: index % 4 == 3 ? 0 : 0,
//                               ),
//                               child: TableGridButtonWidget(
//                                 label: data[index].toString(),
//                                 tableNumber: data[index],
//                                 isSelected: isSelected,
//                                 onPressed: () {
//                                   setState(() {
//                                     selectedTable = data[index];
//                                   });
//                                   showDialog(
//                                     context: context,
//                                     builder: (context) {
//                                       return CustomDialog(
//                                         tableNumber: data[index],
//                                       );
//                                     },
//                                   );
//                                 },
//                               ),
//                             );
//                           },
//                         ),
//                 )),
//             Padding(
//               padding: const EdgeInsets.only(left: 16, right: 16),
//               child: Center(
//                 child: FittedBox(
//                   // fit: BoxFit.scaleDown,
//                   child: ButtonWidget(
//                     text: "Return to Base",
//                     onPressed: () {
//                       ref.context.loaderOverlay.show();
//                       ref.read(basePointVMProvider.notifier)
//                           .triggerReturnToBase();
//                     },
//                     isActive: true,
//                     width: MediaQuery.of(context).size.width * 0.25,
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class CustomDialog extends ConsumerStatefulWidget {
//   final int? tableNumber;
//
//   const CustomDialog({super.key, this.tableNumber});
//
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _CustomDialogState();
// }
//
// class _CustomDialogState extends ConsumerState<CustomDialog> {
//   int? _selectedValue = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen(
//       routeVMProvider,
//       (previous, next) {
//         if (next.toUpperCase() == ROSConstants.success) {
//           context.loaderOverlay.hide();
//           showSuccessToast(
//               context: context,
//               description: "Point added successfully");
//         }
//       },
//     );
//     return AlertDialog(
//       title: const Text('Save Points'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           RadioListTile(
//             title: const Text('Base to Table'),
//             value: 0,
//             groupValue: _selectedValue,
//             onChanged: (value) {
//               setState(() {
//                 _selectedValue = value;
//               });
//             },
//           ),
//           RadioListTile(
//             title: const Text('Table to Base'),
//             value: 1,
//             groupValue: _selectedValue,
//             onChanged: (value) {
//               setState(() {
//                 _selectedValue = value;
//               });
//             },
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel')),
//         ElevatedButton(
//           onPressed: () {
//             context.loaderOverlay.show();
//             ref.read(routeVMProvider.notifier).sendRouteData(
//                 table: widget.tableNumber!, route: _selectedValue!);
//           },
//           child: const Text('Save'),
//         )
//       ],
//     );
//   }
// }
