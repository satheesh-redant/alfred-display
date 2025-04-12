import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:alfred/providers/table_providers.dart';

class TableGridButtonWidget extends ConsumerWidget {
  final String label;
  final bool isDashed;
  final int? tableNumber;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool isDisabled;

  const TableGridButtonWidget({
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

    // Button content
    Widget buttonContent = SizedBox(
      width: 138,
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8), // Reduced from 35 to 8
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
        ),
      ),
    );

    // For the "Add Table" button (isDashed = true)
    if (isDashed) {
      return DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(8),
        dashPattern: const [4, 4],
        color: isDisabled ? Colors.grey[300]! : const Color(0xFF757575),
        strokeWidth: 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isTraining ? null : onPressed, // Disabled during training
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: ShapeDecoration(
                color: shouldBeSelected ? Colors.black : Colors.white.withOpacity(0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: buttonContent,
            ),
          ),
        ),
      );
    }

    // For regular table buttons
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
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
          child: buttonContent,
        ),
      ),
    );
  }
}
