import 'package:alfred/src/shared/providers/system_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slider_button/slider_button.dart';
import 'package:google_fonts/google_fonts.dart';

class PowerOffDialog extends ConsumerWidget {
  const PowerOffDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PowerOffDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalVM = ref.read(systemViewModelProvider.notifier);

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      actionsPadding: const EdgeInsets.only(bottom: 24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.power_settings_new_rounded,
            size: 70,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          Text(
            "Are you sure you want to\npower off Alfred?",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Waiting for robot acknowledgment...",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 30),
        ],
      ),
      actions: [
        Center(
          child: SliderButton(
            action: () async {
              Navigator.pop(context);
              await globalVM.powerOff();
              // Loading indicator will show in sidebar
              // Navigation happens automatically when ACK received
              return true;
            },
            label: Text(
              "Slide to Power Off",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            icon: Icon(Icons.power_settings_new, color: Colors.white),
            width: 250,
            height: 60,
            buttonSize: 60,
            buttonColor: Colors.red,
            backgroundColor: Colors.grey.shade200,
            baseColor: Colors.black,
            highlightedColor: Colors.red.shade700,
          ),
        ),
      ],
    );
  }
}
