import 'dart:convert';

import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/models/boot_check_state.dart';
import 'package:alfred/providers/ros_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/core/core.dart';
import 'package:rosbridge/core/service.dart';
import 'package:rosbridge/core/topic.dart';

class BootCheckViewModel extends StateNotifier<BootCheckResponse> {
  final ROSService _rosService;
  Topic? _topic;

  Map<String, dynamic> requestData = {};

  BootCheckViewModel(this._rosService) : super(BootCheckResponse());

  void init() {
    print('Subscribing boot check topic...');
    _topic = _rosService.createTopic(
      ROSConstants.topicBootCheck,
      ROSConstants.msgString,
      throttleRate: 500,
    );
    // _topic!.subscribe(_responseHandler);
    BootCheckResponse response = BootCheckResponse();
    response.message = 'OK';
    response.overallStatus = 'OK';
    response.checks = [];
    state = response;
  }

  Future<void> _responseHandler(Map<String, dynamic> message) async {
    print(message);
    var bootStatus = jsonDecode(message['data']);
    state = BootCheckResponse.fromJson(bootStatus);
  }

  void setData() {
    state = BootCheckResponse();
  }

  void clearTopic() {
    _topic!.unsubscribe();
  }

  @override
  void dispose() {
    _topic!.unsubscribe();
    super.dispose();
  }
}

final bootCheckVMProvider = StateNotifierProvider.autoDispose<BootCheckViewModel, BootCheckResponse>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return BootCheckViewModel(rosService);
});
