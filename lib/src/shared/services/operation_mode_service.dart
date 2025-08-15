import 'dart:async';

import '../../core/configs/ros_constants.dart';
import '../../core/services/ros_service.dart';

enum OperationMode { training, delivery, unknown }

class OperationModeService {
  final ROSService _rosService;

  static const String _opsModeTopic = '/ops_mode';

  final StreamController<OperationMode> _operationController =
      StreamController<OperationMode>.broadcast();

  Stream<OperationMode> get operationStream => _operationController.stream;
  OperationMode _currentMode = OperationMode.unknown;

  OperationMode get currentMode => _currentMode;

  OperationModeService(this._rosService);

  void subscribeToOpsMode() {
    _rosService.subscribeToTopic(_opsModeTopic, ROSConstants.stringMessageType,
        (message) {
      try {
        final data = message['data'] as String;
        final mode = _parseOperationMode(data);
        if (_currentMode != mode) {
          print('Operation mode: $mode');
          _currentMode = mode;
          _operationController.add(mode);
        }
      } catch (e) {
        print('Ops mode parse error: $e');
        _operationController.addError('Failed to parse ops mode: $e');
      }
    });
  }

  OperationMode _parseOperationMode(String data) {
    switch (data.toLowerCase()) {
      case 'training':
        return OperationMode.training;
      case 'delivery':
        return OperationMode.delivery;
      default:
        return OperationMode.unknown;
    }
  }

  void unsubscribe() {
    _rosService.unsubscribeFromTopic(_opsModeTopic);
  }

  void dispose() {
    unsubscribe();
    _operationController.close();
  }
}
