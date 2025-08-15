import 'dart:async';
import '../../core/configs/ros_constants.dart';
import '../../core/services/ros_service.dart';

class DeliveryService {
  final ROSService _rosService;

  static const String _getTableListTopic = '/get_table_list';
  static const String _tableListTopic = '/table_list';
  static const String _gotoPointTopic = '/goto_point';
  static const String _deliveryStatusTopic = '/delivery_status';

  final StreamController<String> _deliveryStatusController =
      StreamController<String>.broadcast();
  final StreamController<List<int>> _tableListController =
      StreamController<List<int>>.broadcast();

  Stream<String> get deliveryStatusStream => _deliveryStatusController.stream;

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
    try {
      final status = message['data'] as String? ?? '';
      print('Delivery status received: $status');
      _deliveryStatusController.add(status);
    } catch (e) {
      print('Boot check parse error: $e');
      _deliveryStatusController.addError('Failed to parse delivery status response: $e');
    }
  }

  void _handleTableList(Map<String, dynamic> message) {
    try {
      final data = message['data'] as String? ?? '';
      print('Table list received: $data');
      final tableNumbers = data
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.tryParse(s.trim()))
          .where((n) => n != null)
          .cast<int>()
          .toList();
      _tableListController.add(tableNumbers);
    } catch (e) {
      print('Boot check parse error: $e');
      _deliveryStatusController.addError('Failed to parse table list response: $e');
    }
  }

  Future<void> requestTableList() async {
    print('Requesting table list...');
    final data = <String, dynamic>{}; // Empty message
    await _rosService.publishToTopic(
        _getTableListTopic, ROSConstants.emptyMessageType, data);
  }

  Future<void> gotoPoint(int tableNumber, int route) async {
    final data = {'data': '$tableNumber:$route'};
    print('Publishing goto_point: $data');
    await _rosService.publishToTopic(_gotoPointTopic, ROSConstants.stringMessageType, data);
  }

  void dispose() {
    _rosService.unsubscribeFromTopic(_deliveryStatusTopic);
    _rosService.unsubscribeFromTopic(_tableListTopic);
    _deliveryStatusController.close();
    _tableListController.close();
  }
}
