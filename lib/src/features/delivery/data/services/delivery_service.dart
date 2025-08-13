import 'dart:async';
import 'package:alfred/config/ros_constants.dart';

import '../../../../core/services/ros_service.dart';

class DeliveryService {
  final ROSService _rosService;

  static const String _moveTableTopic = '/move_table';
  static const String _deliveryStatusTopic = '/delivery_status';
  static const String _tableListTopic = '/table_list';
  static const String _requestTableListTopic = '/get_table_list';

  final StreamController<DeliveryStatusUpdate> _deliveryStatusController =
      StreamController<DeliveryStatusUpdate>.broadcast();
  final StreamController<List<int>> _tableListController =
      StreamController<List<int>>.broadcast();

  Stream<DeliveryStatusUpdate> get deliveryStatusStream =>
      _deliveryStatusController.stream;

  Stream<List<int>> get tableListStream => _tableListController.stream;

  DeliveryService(this._rosService) {
    _initializeSubscriptions();
  }

  void _initializeSubscriptions() {
    _rosService.subscribeToTopic(
      _deliveryStatusTopic,
      ROSConstants.stringMessageType,
      _handleDeliveryStatus,
    );

    _rosService.subscribeToTopic(
      _tableListTopic,
      ROSConstants.stringMessageType,
      _handleTableList,
    );
  }

  void _handleDeliveryStatus(Map<String, dynamic> message) {
    final status = message['data'] as String? ?? '';
    final update = DeliveryStatusUpdate.fromString(status);
    _deliveryStatusController.add(update);
  }

  void _handleTableList(Map<String, dynamic> message) {
    final data = message['data'] as String? ?? '';
    final tableNumbers = data
        .split(',')
        .where((s) => s.isNotEmpty)
        .map((s) => int.tryParse(s.trim()))
        .where((n) => n != null)
        .cast<int>()
        .toList();
    _tableListController.add(tableNumbers);
  }

  Future<void> moveToTable(int tableNumber, int route) async {
    final data = {'data': '$tableNumber:$route'};
    await _rosService.publishToTopic(_moveTableTopic, ROSConstants.stringMessageType, data);
  }

  Future<void> requestTableList() async {
    final data = {};
    await _rosService.publishToTopic(_requestTableListTopic, ROSConstants.emptyMessageType, data);
  }

  void dispose() {
    _rosService.unsubscribeFromTopic(_deliveryStatusTopic);
    _rosService.unsubscribeFromTopic(_tableListTopic);
    _deliveryStatusController.close();
    _tableListController.close();
  }
}

// Helper class for delivery status updates
class DeliveryStatusUpdate {
  final String status; // "moving" or "delivered"
  final int? tableNumber;
  final int? route;

  const DeliveryStatusUpdate({
    required this.status,
    this.tableNumber,
    this.route,
  });

  factory DeliveryStatusUpdate.fromString(String data) {
    // If the data contains table and route info: "moving:5:0"
    final parts = data.split(':');
    if (parts.length >= 3) {
      return DeliveryStatusUpdate(
        status: parts[0],
        tableNumber: int.tryParse(parts[1]),
        route: int.tryParse(parts[2]),
      );
    }

    // Simple status: "moving" or "delivered"
    return DeliveryStatusUpdate(status: data);
  }

  bool get isMoving => status.toLowerCase() == 'moving';

  bool get isDelivered => status.toLowerCase() == 'delivered';
}
