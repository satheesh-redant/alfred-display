import 'package:alfred/view_models/base_point_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SaveStartingPointDialog extends ConsumerWidget {
  final VoidCallback onConfirmed;

  const SaveStartingPointDialog({required this.onConfirmed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.listen(basePointVMProvider, (prev, next) {
    //   Navigator.pop(context); // Close dialog
    // });
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    print("Building SaveStartingPointDialog...");
    print("isMobile: $isMobile");

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16.0 : 0.0,
        vertical: 24.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Colors.white, width: 2.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Save your Base Point",
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    color: Color(0xFF1D1B20),
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Divider(color: Colors.grey, thickness: 1.0),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      print("Cancel button pressed");
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25.0,
                        vertical: 20.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  FilledButton(
                    onPressed: () {
                      print("Yes button pressed");
                      Navigator.pop(context);
                      onConfirmed();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 45.0,
                        vertical: 20.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      "Yes",
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:responsive_framework/responsive_framework.dart';
//
// class SaveStartingPointDialog extends StatelessWidget {
//   final VoidCallback onConfirmed;
//
//   const SaveStartingPointDialog({required this.onConfirmed});
//
//   @override
//   Widget build(BuildContext context) {
//     final isMobile = ResponsiveBreakpoints.of(context).isMobile;
//
//     return Dialog(
//       backgroundColor: Colors.white,
//       insetPadding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16.0 : 0.0,
//         vertical: 24.0,
//       ),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.0),
//         side: const BorderSide(color: Colors.white, width: 2.0),
//       ),
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: isMobile ? double.infinity : 500.0,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Save your Base Point",
//                 style: GoogleFonts.roboto(
//                   textStyle: const TextStyle(
//                     color: Color(0xFF1D1B20),
//                     fontSize: 24.0,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16.0),
//               const Divider(color: Colors.grey, thickness: 1.0),
//               const SizedBox(height: 24.0),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 25.0,
//                         vertical: 20.0,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                     ),
//                     child: Text(
//                       "Cancel",
//                       style: GoogleFonts.roboto(
//                         textStyle: const TextStyle(
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16.0),
//                   FilledButton(
//                     onPressed: onConfirmed,
//                     style: FilledButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 45.0,
//                         vertical: 20.0,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                     ),
//                     child: Text(
//                       "Yes",
//                       style: GoogleFonts.roboto(
//                         textStyle: const TextStyle(
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
