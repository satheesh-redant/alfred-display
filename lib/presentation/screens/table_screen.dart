import 'package:flutter/material.dart';
import 'package:alfred/config/alfred_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:alfred/providers/table_providers.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/table.dart';

class TableScreen extends ConsumerWidget {
  const TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tableProvider);
    final selectedTable = ref.watch(selectedTableProvider);
    final isTraining = ref.watch(isTrainingProvider);

    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Section (Text + Image) - unchanged
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 355,
                          height: 49,
                          margin: const EdgeInsets.only(top: 25, left: 61),
                          alignment: Alignment.center,
                          child: Text.rich(
                            TextSpan(
                              text: "Move Alfred manually, place it towards the table and click on ",
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 24.2 / 18,
                                color: Colors.black,
                              ),
                              children: [
                                TextSpan(
                                  text: "Table Number",
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    height: 24.2 / 18,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                        Image.asset(
                          "assets/images/alfred_base.png",
                          width: 450,
                          height: 400,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Right Section (Table Buttons + Add Table)

                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.only(top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mark Tables",
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Table Grid View
                        
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(right: 35),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 35,
                              mainAxisSpacing: 30,
                              childAspectRatio: 138 / 60,
                            ),
                            itemCount: tables.length + 1,
                            itemBuilder: (context, index) {
                              if (index < tables.length) {
                                final isSelected = selectedTable == tables[index];
                                final isDisabled = isTraining && !isSelected;

                                return TableGridButton(
                                  label: tables[index].toString(),
                                  tableNumber: tables[index],
                                  isSelected: isSelected,
                                  isDisabled: isDisabled,
                                  onPressed: isDisabled
                                      ? null
                                      : () {
                                    ref.read(selectedTableProvider.notifier).state =
                                    isSelected ? null : tables[index];
                                  },
                                );
                              } else {
                                // Add Table Button - always disabled during training
                                return DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(8),
                                  dashPattern: const [4, 4],
                                  color: isTraining ? Colors.grey[300]! : const Color(0xFF757575),
                                  strokeWidth: 1,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: isTraining
                                          ? null
                                          : () => ref.read(tableProvider.notifier).addTable(),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Center(
                                        child: Text(
                                          "Add Table",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: isTraining
                                                ? Colors.grey[300]
                                                : const Color(0xFF757575),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Control Button (Return to Base/Finish Training)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 50, top: 20, left: 528),
                child: SizedBox(
                  width: 655,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (isTraining) {
                            // Finish training and navigate
                            ref.read(isTrainingProvider.notifier).state = false;
                            context.pushReplacement(AlfredConstants.routeBaseScreen);
                          } else {
                            // Start training mode if table is selected
                            if (selectedTable != null) {
                              ref.read(isTrainingProvider.notifier).state = true;
                            } else {
                              // Return to base if no table selected
                              context.pushReplacement(AlfredConstants.routeBaseScreen);
                            }
                          }
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              isTraining
                                  ? "Finish Training"
                                  : "Return to Base",
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                height: 24.2 / 22,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:alfred/config/alfred_constants.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:alfred/providers/table_providers.dart';
// import 'package:go_router/go_router.dart';
// import '../widgets/custom_appbar.dart';
// import '../widgets/table.dart';
//
// class TableScreen extends ConsumerWidget {
//   const TableScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final tables = ref.watch(tableProvider);
//     final selectedTable = ref.watch(selectedTableProvider);
//     final isTraining = ref.watch(isTrainingProvider);
//
//     return Scaffold(
//       appBar: CustomAppBar(),
//       body: Padding(
//         padding: const EdgeInsets.all(15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Left Section (Text + Image)
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                     padding: const EdgeInsets.only(top: 30),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Instruction Text
//                         Container(
//                           width: 355,
//                           height: 49,
//                           margin: const EdgeInsets.only(top: 25, left: 61),
//                           alignment: Alignment.center,
//                           child: Text.rich(
//                             TextSpan(
//                               text: "Move Alfred manually, place it towards the table and click on ",
//                               style: GoogleFonts.inter(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w400,
//                                 height: 24.2 / 18,
//                                 color: Colors.black,
//                               ),
//                               children: [
//                                 TextSpan(
//                                   text: "Table Number",
//                                   style: GoogleFonts.inter(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w700,
//                                     height: 24.2 / 18,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 60),
//                         // Image Display
//                         Image.asset(
//                           "assets/images/alfred_base.png",
//                           width: 450,
//                           height: 400,
//                           fit: BoxFit.contain,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//
//                 // Right Section (Table Buttons + Add Table)
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     padding: const EdgeInsets.only(top: 50),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           isTraining ? "Training Table ${selectedTable}" : "Mark Tables",
//                           style: GoogleFonts.nunito(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 40),
//
//                         // Table Grid View
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.only(right: 35),
//                           child: GridView.builder(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 4,
//                               crossAxisSpacing: 35,
//                               mainAxisSpacing: 30,
//                               childAspectRatio: 138 / 60,
//                             ),
//                             itemCount: tables.length + 1,
//                             itemBuilder: (context, index) {
//                               if (index < tables.length) {
//                                 final isSelected = selectedTable == tables[index];
//                                 final isDisabled = isTraining && !isSelected;
//
//                                 return TableGridButton(
//                                   label: tables[index].toString(),
//                                   tableNumber: tables[index],
//                                   onPressed: () {
//                                     if (!isTraining) {
//                                       ref.read(selectedTableProvider.notifier).state =
//                                       selectedTable == tables[index] ? null : tables[index];
//                                     }
//                                   },
//                                 );
//
//                               } else {
//                                 // Add Table Button
//                                 return DottedBorder(
//                                   borderType: BorderType.RRect,
//                                   radius: const Radius.circular(8),
//                                   dashPattern: const [4, 4],
//                                   color: isTraining ? Colors.grey[300]! : const Color(0xFF757575),
//                                   strokeWidth: 1,
//                                   child: Material(
//                                     color: Colors.transparent,
//                                     child: InkWell(
//                                       onTap: isTraining
//                                           ? null
//                                           : () => ref.read(tableProvider.notifier).addTable(),
//                                       borderRadius: BorderRadius.circular(8),
//                                       child: Center(
//                                         child: Text(
//                                           "Add Table",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                             color: isTraining
//                                                 ? Colors.grey[300]
//                                                 : const Color(0xFF757575),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             // Training Control Button
//             Align(
//               alignment: Alignment.centerRight,
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 50, top: 20, left: 528),
//                 child: SizedBox(
//                   width: 655,
//                   height: 80,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: Colors.black,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.3),
//                           blurRadius: 3,
//                           offset: const Offset(0, 1),
//                         ),
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.15),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                           spreadRadius: 3,
//                         ),
//                       ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(8),
//                         onTap: () {
//                           if (isTraining) {
//                             // Finish training
//                             ref.read(isTrainingProvider.notifier).state = false;
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text('Training completed successfully'),
//                                 duration: Duration(seconds: 2),
//                               ),
//                             );
//                             context.pushReplacement(AlfredConstants.routeBaseScreen);
//                           } else if (selectedTable != null) {
//                             // Start training
//                             ref.read(isTrainingProvider.notifier).state = true;
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Started training for table $selectedTable'),
//                                 duration: const Duration(seconds: 2),
//                               ),
//                             );
//                           } else {
//                             // Return to base
//                             context.pushReplacement(AlfredConstants.routeBaseScreen);
//                           }
//                         },
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 20),
//                             child: Text(
//                               isTraining
//                                   ? "Finish Training"
//                                   : selectedTable != null
//                                   ? "Start Training"
//                                   : "Return to Base",
//                               style: GoogleFonts.inter(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w600,
//                                 height: 24.2 / 22,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:alfred/config/alfred_constants.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:alfred/providers/table_providers.dart';
// import 'package:go_router/go_router.dart';
// import '../widgets/table.dart';
// import '../widgets/custom_appbar.dart';
//
// class TableScreen extends ConsumerWidget {
//   const TableScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final tables = ref.watch(tableProvider);
//     final selectedTable = ref.watch(selectedTableProvider);
//
//     return Scaffold(
//       appBar: CustomAppBar(),
//       body: Padding(
//         padding: const EdgeInsets.all(15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Left Section (Text + Image)
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                     padding: const EdgeInsets.only(top: 30),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Instruction Text
//                         Container(
//                           width: 355,
//                           height: 49,
//                           margin: const EdgeInsets.only(top: 25, left: 61),
//                           alignment: Alignment.center,
//                           child: Text.rich(
//                             TextSpan(
//                               text: "Move Alfred manually, place it towards the table and click on ",
//                               style: GoogleFonts.inter(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w400,
//                                 height: 24.2 / 18,
//                                 color: Colors.black,
//                               ),
//                               children: [
//                                 TextSpan(
//                                   text: "Table Number",
//                                   style: GoogleFonts.inter(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w700,
//                                     height: 24.2 / 18,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 60),
//                         // Image Display
//                         Image.asset(
//                           "assets/images/alfred_base.png",
//                           width: 450,
//                           height: 400,
//                           fit: BoxFit.contain,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//
//                 // Right Section (Table Buttons + Add Table)
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     padding: const EdgeInsets.only(top: 50),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Mark Tables",
//                           style: GoogleFonts.nunito(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 40),
//
//                         // Table Grid View
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.only(right: 35),
//                           child: GridView.builder(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 4,
//                               crossAxisSpacing: 35,
//                               mainAxisSpacing: 30,
//                               childAspectRatio: 138 / 60,
//                             ),
//                             itemCount: tables.length + 1, // +1 for the "Add Table" button
//                             itemBuilder: (context, index) {
//                               if (index < tables.length) {
//                                 final isSelected = selectedTable == tables[index];
//
//                                 return TableGridButton(
//                                   label: tables[index].toString(),
//                                   tableNumber: tables[index],
//                                   isSelected: isSelected,
//                                   onPressed: () {
//                                     ref.read(selectedTableProvider.notifier).state =
//                                     isSelected ? null : tables[index];
//                                   },
//                                 );
//                               } else {
//                                 // Add Table Button
//                                 return DottedBorder(
//                                   borderType: BorderType.RRect,
//                                   radius: const Radius.circular(8),
//                                   dashPattern: const [4, 4],
//                                   color: const Color(0xFF757575),
//                                   strokeWidth: 1,
//                                   child: Material(
//                                     color: Colors.transparent,
//                                     child: InkWell(
//                                       onTap: () => ref.read(tableProvider.notifier).addTable(),
//                                       borderRadius: BorderRadius.circular(8),
//                                       child: const Center(
//                                         child: Text(
//                                           "Add Table",
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                             color: Color(0xFF757575),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//
//             // Finish Training / Return to Base Button
//             Align(
//               alignment: Alignment.centerRight,
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 50, top: 20, left: 528),
//                 child: SizedBox(
//                   width: 655,
//                   height: 80,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: Colors.black,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.3),
//                           blurRadius: 3,
//                           offset: const Offset(0, 1),
//                         ),
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.15),
//                           blurRadius: 8,
//                           offset: const Offset(0, 4),
//                           spreadRadius: 3,
//                         ),
//                       ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(8),
//                         onTap: () {
//                           if (selectedTable != null) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Finished training for table $selectedTable'),
//                                 duration: const Duration(seconds: 2),
//                               ),
//                             );
//                             context.pushReplacement(AlfredConstants.routeBaseScreen);
//                           }
//                           ref.read(selectedTableProvider.notifier).state = null;
//                         },
//                         child: Center(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 20),
//                             child: Text(
//                               selectedTable != null ? "Finish Training" : "Return to Base",
//                               style: GoogleFonts.inter(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w600,
//                                 height: 24.2 / 22,
//                                 color: Colors.white,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

