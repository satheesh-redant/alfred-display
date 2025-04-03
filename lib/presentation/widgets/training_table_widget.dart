import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:alfred/providers/table_providers.dart';

class TableGridButton extends ConsumerWidget {
  final String label;
  final bool isDashed;
  final int? tableNumber;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool isDisabled;

  const TableGridButton({
    super.key,
    required this.label,
    this.isDashed = false,
    this.tableNumber,
    this.onPressed,
    this.isSelected = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTraining = ref.watch(isTrainingProvider);
    final shouldBeSelected = isSelected || (!isDashed && ref.watch(selectedTableProvider) == tableNumber);

    // Modified button content with selection highlight
    final buttonContent = Container(
      width: 138,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 17),
      decoration: ShapeDecoration(
        color: shouldBeSelected ? Colors.black : Colors.white.withOpacity(0),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 0.50,
            color: isDisabled
                ? Colors.grey[300]!
                : shouldBeSelected ? Colors.black : const Color(0xFF757575),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            height: 1.20,
            letterSpacing: 0.20,
            color: isDisabled
                ? Colors.grey[300]
                : shouldBeSelected ? Colors.white : const Color(0xFF757575),
          ),
        ),
      ),
    );

    // Original interactive logic remains exactly the same
    return isDashed
        ? DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(8),
      dashPattern: const [4, 4],
      color: isDisabled ? Colors.grey[300]! : const Color(0xFF757575),
      strokeWidth: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(8),
          child: buttonContent,
        ),
      ),
    )
        : Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(8),
        child: buttonContent,
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:alfred/providers/table_providers.dart';
//
// class TableGridButton extends ConsumerWidget {
//   final String label;
//   final bool isDashed;
//   final int? tableNumber;
//   final VoidCallback? onPressed;
//   final bool isSelected;
//   final bool isDisabled;
//
//   const TableGridButton({
//     super.key,
//     required this.label,
//     this.isDashed = false,
//     this.tableNumber,
//     this.onPressed,
//     this.isSelected = false,
//     this.isDisabled = false,
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isTraining = ref.watch(isTrainingProvider);
//     final shouldBeSelected = isSelected || (!isDashed && ref.watch(selectedTableProvider) == tableNumber);
//
//     return SizedBox(
//       width: 138,
//       height: 60,
//       child: isDashed
//           ? DottedBorder(
//         borderType: BorderType.RRect,
//         radius: const Radius.circular(8),
//         padding: EdgeInsets.zero,
//         dashPattern: const [4, 4],
//         color: isDisabled ? Colors.grey[300]! : const Color(0xFF757575),
//         strokeWidth: 1.5,
//         child: Material(
//           color: Colors.white, // White background for disabled state
//           child: InkWell(
//             onTap: isDisabled ? null : onPressed,
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               width: double.infinity,
//               height: double.infinity,
//               alignment: Alignment.center,
//               child: Text(
//                 label,
//                 style: GoogleFonts.nunito(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w400,
//                   color: isDisabled ? Colors.grey[300] : const Color(0xFF757575),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       )
//           : Container(
//         decoration: BoxDecoration(
//           color: isDisabled
//               ? Colors.white // White background when disabled
//               : (shouldBeSelected ? Colors.black : Colors.white),
//           border: Border.all(
//             color: isDisabled
//                 ? Colors.grey[300]!
//                 : (shouldBeSelected ? Colors.black : const Color(0xFF757575)),
//             width: 1.5,
//           ),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: isDisabled ? null : onPressed,
//             borderRadius: BorderRadius.circular(8),
//             child: Center(
//               child: Text(
//                 label,
//                 style: GoogleFonts.nunito(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: isDisabled
//                       ? Colors.grey[400]
//                       : (shouldBeSelected ? Colors.white : Colors.black),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
