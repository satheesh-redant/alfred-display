import 'package:flutter/material.dart';
import '../../data/models/delivery_models.dart';

class DeliveryStatusWidget extends StatelessWidget {
  final DeliveryData deliveryState;

  const DeliveryStatusWidget({
    super.key,
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
    if (deliveryState.state == DeliveryState.moving) {
      return 'assets/images/alfred_moving.png';
    } else if (deliveryState.state == DeliveryState.delivered) {
      /*if (deliveryState.isBaseToTable) {
        return 'assets/images/alfred_arrived.png'; // At table
      } else {
        return 'assets/images/alfred_base.png'; // Back at base
      }*/
      return 'assets/images/alfred_ready.png';
    }
    return 'assets/images/alfred_ready.png'; // Default
  }
}
