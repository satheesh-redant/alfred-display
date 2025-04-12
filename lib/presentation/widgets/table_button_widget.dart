
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class TableButtonWidget extends StatelessWidget {
  final int tableNumber;
  final bool isSelected;
  final VoidCallback onTap;
  const TableButtonWidget({
    Key? key,
    required this.tableNumber,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: isSelected ? Colors.blue : Colors.grey,
        dashPattern: const [6, 3],
        strokeWidth: 2,
        child: Container(
          alignment: Alignment.center,
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
          child: Text('Table $tableNumber'),
        ),
      ),
    );
  }
}
