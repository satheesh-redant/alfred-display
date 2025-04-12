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
  final bool isMarked;

  const TableGridButtonWidget({
    super.key,
    required this.label,
    this.isDashed = false,
    this.tableNumber,
    this.onPressed,
    this.isSelected = false,
    this.isDisabled = false,
    this.isMarked = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTraining = ref.watch(isTrainingProvider);
    final selectedTable = ref.watch(selectedTableProvider);

    // Show as selected if either:
    // 1. It's the currently selected table (before confirmation)
    // 2. It's marked as selected (after confirmation)
    final showSelected = isSelected || (!isDashed && selectedTable == tableNumber);
    final showMarked = isMarked && !showSelected;
    final showDisabled = isDisabled && !showSelected;

    // Colors - Selected gets solid black background
    final backgroundColor = showSelected
        ? Colors.black // Solid black for selected
        : showMarked
        ? Colors.grey[100]!
        : Colors.transparent;

    final textColor = showSelected
        ? Colors.white // White text on black
        : showMarked
        ? Colors.grey[400]!
        : showDisabled
        ? Colors.grey[300]!
        : const Color(0xFF757575);

    final borderColor = showSelected
        ? Colors.black // Black border for selected
        : showMarked
        ? Colors.grey[400]!
        : showDisabled
        ? Colors.grey[300]!
        : const Color(0xFF757575);

    Widget buttonContent = SizedBox(
      width: 138,
      height: 60,
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: showMarked ? FontWeight.w300 : FontWeight.w400,
            color: textColor,
          ),
        ),
      ),
    );

    if (isDashed) {
      return DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(8),
        dashPattern: const [4, 4],
        color: borderColor,
        strokeWidth: 1,
        child: Material(
          color: backgroundColor,
          child: InkWell(
            onTap: isTraining || showDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(8),
            child: buttonContent,
          ),
        ),
      );
    }

    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: showDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: buttonContent,
        ),
      ),
    );
  }
}
