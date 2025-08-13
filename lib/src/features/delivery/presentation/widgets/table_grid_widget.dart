import 'package:flutter/material.dart';

class TableGridWidget extends StatelessWidget {
  final int tableNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const TableGridWidget({
    super.key,
    required this.tableNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            'Table $tableNumber',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}