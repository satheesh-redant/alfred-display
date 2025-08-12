import 'dart:convert';

import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/models/boot_check_state.dart';
import 'package:alfred/providers/ros_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/core/core.dart';
import 'package:rosbridge/core/topic.dart';

class BootCheckViewModel extends StateNotifier<BootCheckResponse> {
  final ROSService _rosService;
  Topic? _topic;

  Map<String, dynamic> requestData = {};

  BootCheckViewModel(this._rosService) : super(BootCheckResponse());

  void init() {
    print('initiating boot status topics');
    _topic = _rosService.createTopic(
      ROSConstants.topicBootCheck,
      ROSConstants.msgString,
      throttleRate: 500,
    );
    _topic!.subscribe(_responseHandler);
    // BootCheckResponse response = BootCheckResponse();
    // response.message = 'OK';
    // response.overallStatus = 'OK';
    // response.checks = [];
    // state = response;
  }

  Future<void> _responseHandler(Map<String, dynamic> message) async {
    print('Boot check data: $message');
    var bootStatus = jsonDecode(message['data']);
    state = BootCheckResponse.fromJson(bootStatus);
  }

  void clearTopic() {
    print('Unsubscribing to boot status topic');
    _topic!.unsubscribe();
  }

  @override
  void dispose() {
    print('Disposing all boot status topics');
    _topic!.unsubscribe();
  }
}

final bootCheckVMProvider = StateNotifierProvider.autoDispose<BootCheckViewModel, BootCheckResponse>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final bootCheckVM = BootCheckViewModel(rosService);
  ref.onDispose(() => bootCheckVM.dispose());
  return bootCheckVM;
});
