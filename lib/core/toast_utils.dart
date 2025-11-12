import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

void showSuccessToast({
  required BuildContext context,
  required String description,
}) {
  showToast(context, description, 'Success', ToastificationType.success);
}

void showErrorToast({
  required BuildContext context,
  required String description,
}) {
  showToast(context, description, 'Error', ToastificationType.error);
}

void showToast(BuildContext context, String description, String title,
    ToastificationType type) {
  toastification.show(
    context: context,
    type: type,
    style: ToastificationStyle.flat,
    title: Text(title),
    description: Text(description),
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 2),
    animationBuilder: (context, animation, alignment, child) {
      return ScaleTransition(scale: animation, child: child);
    },
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: highModeShadow,
    // Make sure this is defined
    showProgressBar: true,
    pauseOnHover: false,
  );
}

void showLowBatteryWarning({
  required BuildContext context,
  required int batteryPercentage,
  void Function()? onClose,
}) {
  toastification.showCustom(
    context: context,
    alignment: Alignment.topCenter,
    animationBuilder: (context, animation, alignment, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      );
    },
    builder: (context, holder) {
      return Align(
        alignment: AlignmentGeometry.topCenter,
        child: Container(
          width: 600,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: const Color(0x40000000),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1E9),
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max, // Use maximum available width
                children: [
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/images/icon_low_battery.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Low battery under $batteryPercentage%. Please connect to a charger.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFFFF6B00),
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      toastification.dismissById(holder.id);
                      onClose?.call();
                    },
                    icon: SvgPicture.asset(
                      'assets/images/icon_cancel.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      );
    },
  );
}

