import 'package:flutter/material.dart';
import '../../data/models/delivery_models.dart';

class DeliveryStatusWidget extends StatelessWidget {
  final DeliveryProgressStage progressStage;
  final DeliveryState deliveryState;

  const DeliveryStatusWidget({
    super.key,
    required this.progressStage,
    required this.deliveryState,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath = _getImagePath();

    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    );
  }

  String _getImagePath() {
    switch (progressStage) {
      case DeliveryProgressStage.baseToTable:
        return 'assets/images/alfred_moving.png'; // Moving to table
      case DeliveryProgressStage.baseToTableFinished:
        return 'assets/images/alfred_ready.png'; // Arrived at table
      case DeliveryProgressStage.tableToBase:
        return 'assets/images/alfred_moving.png'; // Returning to base
      case DeliveryProgressStage.tableToBaseFinished:
        return 'assets/images/alfred_ready.png'; // Back at base
    }
  }
}
