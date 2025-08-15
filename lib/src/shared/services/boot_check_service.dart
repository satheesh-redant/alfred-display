import 'dart:async';
import 'dart:convert';

import '../../core/configs/ros_constants.dart';
import '../../core/services/ros_service.dart';
import '../models/boot_check_response.dart';

class BootCheckService {
  final ROSService _rosService;

  static const String _bootCheckTopic = '/boot_check';

  BootCheckService(this._rosService);

  Stream<BootCheckResponse> subscribeToBootCheck() {
    final controller = StreamController<BootCheckResponse>.broadcast();

    _rosService.subscribeToTopic(_bootCheckTopic, ROSConstants.stringMessageType, (message) {
      try {
        final data = message['data'] as String;
        final jsonData = jsonDecode(data);
        final response = BootCheckResponse.fromJson(jsonData);
        print('Boot check: ${response.overallStatus} - ${response.message}');
        controller.add(response);
      } catch (e) {
        print('Boot check parse error: $e');
        controller.addError('Failed to parse boot check response: $e');
      }
    });

    return controller.stream;
  }

  void dispose() {
    _rosService.unsubscribeFromTopic(_bootCheckTopic);
  }
}
