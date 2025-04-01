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
  final bool isDisabled; // ✅ Added isDisabled parameter

  const TableGridButton({
    super.key,
    required this.label,
    this.isDashed = false,
    this.tableNumber,
    this.onPressed,
    this.isSelected = false,
    this.isDisabled = false, // ✅ Default value set to false
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTraining = ref.watch(isTrainingProvider);
    final shouldBeSelected = isSelected || (!isDashed && ref.watch(selectedTableProvider) == tableNumber);

    return SizedBox(
      width: 138,
      height: 60,
      child: isDashed
          ? DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(8),
        padding: EdgeInsets.zero,
        dashPattern: const [4, 4],
        color: isDisabled ? Colors.grey[300]! : Colors.grey,
        strokeWidth: 1.5,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDisabled ? Colors.grey[300] : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      )
          : ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: shouldBeSelected
              ? Colors.black
              : (isDisabled ? Colors.grey[200] : Colors.white),
          foregroundColor: shouldBeSelected
              ? Colors.white
              : (isDisabled ? Colors.grey : Colors.black),
          side: BorderSide(
            color: shouldBeSelected
                ? Colors.black
                : (isDisabled ? Colors.grey : Colors.grey),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          elevation: 0,
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}


