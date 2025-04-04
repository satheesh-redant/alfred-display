import 'package:alfred/view_models/base_reset_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:alfred/config/alfred_constants.dart';

class SaveStartingPointDialog extends ConsumerWidget {
  const SaveStartingPointDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(baseResetVMProvider, (prev, next) {
      Navigator.pop(context); // Close dialog
    });
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.white, width: 2),
      ),
      title: Text(
        "Save your Base Point",
        style: GoogleFonts.roboto(
          textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Divider(
          color: Colors.grey,
          thickness: 1,
        ),
      ),
      // Adds a subtle divider line
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            textStyle: TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          child: Text(
            "Cancel",
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            // Save base point logic here
            ref.read(baseResetVMProvider.notifier).resetBasePoint();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black, // Black button
            padding: EdgeInsets.symmetric(horizontal: 45, vertical: 20),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          child: Text(
            "Yes",
            style: GoogleFonts.roboto(
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
