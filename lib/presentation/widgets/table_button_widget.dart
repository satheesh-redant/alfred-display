import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class TableButtonWidget extends StatelessWidget {
  final int tableNumber; //todo: Stores the table number identifier
  final bool isSelected; //todo: Tracks selection state (true/false)
  final VoidCallback onTap; //todo: Callback when table is tapped

  const TableButtonWidget({
    super.key,
    required this.tableNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, //todo: Trigger callback on user tap
      child: DottedBorder(
        color: isSelected ? Colors.blue : Colors.grey, //todo: Change border color based on selection
        dashPattern: const [6, 3],
        strokeWidth: 2,
        child: Container(
          alignment: Alignment.center,
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.2), //todo: Change background based on selection
          child: Text('Table $tableNumber'), //todo: Display dynamic table number
        ),
      ),
    );
  }
}
