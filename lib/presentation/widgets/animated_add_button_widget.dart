

import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class AnimatedAddButton extends StatelessWidget {
  final bool isTraining;
  final bool isDisabled;  // Add this new parameter
  final VoidCallback onPressed;
  final bool useSolidBorder;

  const AnimatedAddButton({
    super.key,
    required this.isTraining,
    required this.onPressed,
    this.useSolidBorder = false,
    this.isDisabled = false,  // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 50, end: 0),
      curve: Curves.easeOut,
      builder: (context, offset, child) {
        return Transform.translate(
          offset: Offset(0, offset),
          child: useSolidBorder ? _buildSolidButton() : _buildDottedButton(),
        );
      },
    );
  }

  Widget _buildDottedButton() {
    return SizedBox(
      width: 138,
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: (isTraining || isDisabled) ? null : onPressed,  // Updated condition
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(8),
            padding: EdgeInsets.zero,
            dashPattern: const [4, 4],
            color: (isTraining || isDisabled) ? Colors.grey[300]! : const Color(0xFF757575),  // Updated condition
            strokeWidth: 1,
            child: _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildSolidButton() {
    return SizedBox(
      width: 138,
      height: 60,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: (isTraining || isDisabled) ? null : onPressed,  // Updated condition
          child: Container(
            decoration: ShapeDecoration(
              color: Colors.white.withOpacity(0),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 0.50,
                  color: (isTraining || isDisabled) ? Colors.grey[300]! : const Color(0xFF757575),  // Updated condition
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _buildButtonContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    return Center(
      child: Text(
        "Add Table",
        style: TextStyle(
          color: (isTraining || isDisabled) ? Colors.grey[300]! : const Color(0xFF757575),  // Updated condition
          fontSize: 20,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
