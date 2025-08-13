import 'package:flutter/material.dart';
import '../../../../shared/widgets/common_button_widget.dart';

class DeliveryActionButton extends StatelessWidget {
  final String text;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  const DeliveryActionButton({
    super.key,
    required this.text,
    required this.isEnabled,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: CommonButtonWidget(
        text: text,
        onPressed: isEnabled ? onPressed : null,
        isLoading: isLoading,
      ),
    );
  }
}