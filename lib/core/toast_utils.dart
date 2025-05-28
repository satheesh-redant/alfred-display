
import 'package:flutter/widgets.dart';
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

void showToast(BuildContext context, String description, String title, ToastificationType type) {
  toastification.show(
    context: context,
    type: type,
    style: ToastificationStyle.flat,
    title: Text(title),
    description: Text(description),
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 1),
    animationBuilder: (context, animation, alignment, child) {
      return ScaleTransition(scale: animation, child: child);
    },
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: highModeShadow, // Make sure this is defined
    showProgressBar: true,
    pauseOnHover: false,
  );
}