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
  late final Topic _topic;
  Topic? _triggerTopic;

  Map<String, dynamic> requestData = {};

  BootCheckViewModel(this._rosService) : super(BootCheckResponse());

  void init() {
    print('Subscribing boot check topic...');
    _topic = _rosService.createTopic(
      ROSConstants.topicBootCheck,
      ROSConstants.msgString,
      throttleRate: 500,
    );
    _topic.subscribe(_responseHandler);
  }

  Future<void> _responseHandler(Map<String, dynamic> message) async {
    print(message);
    var bootStatus = jsonDecode(message['data']);
    state = BootCheckResponse.fromJson(bootStatus);
  }

  void setData() {
    state = BootCheckResponse();
  }

  Future<void> reinit() async {
    print('re-initiating boot check topic...');
    /*
    *   JUst for testing t0 and fro data exchange with ros
    * */
    _triggerTopic = _rosService.createTopic(
      '/set_parameter',
      ROSConstants.msgString,
    );
    _triggerTopic!.subscribe((msg) async {
      print("Received echo on trigger topic: $msg");
      // Optionally, cancel the subscription after receiving the echo once.
      _triggerTopic!.unsubscribe();
    });
    // To set a parameter, publish a JSON string:
    Map<String, dynamic> paramUpdate = {
      "param": "boot_check_override_camera",
      "value": "OK"
    };
    // Convert the parameter update map to a JSON string.
    String jsonString = jsonEncode(paramUpdate);
    // Now publish a std_msgs/String message where the "data" field holds your JSON string.
    await _triggerTopic!.publish({
      "data": jsonString
    });

    /*_triggerTopic = _rosService.createTopic(
      ROSConstants.topicTriggerBootCheck,
      ROSConstants.msgEmpty,
    );
    _triggerTopic!.subscribe((msg) async {
      Map<String, dynamic> response = {};
      print("Received echo on trigger topic: $msg");
      // Optionally, cancel the subscription after receiving the echo once.
      _triggerTopic!.unsubscribe();
    });
    await _triggerTopic!.publish({});*/
  }

  // Future<void> init() async {
  //   print('Initializing boot status check...');
  //   service = Service(
  //     name: ROSConstants.bootStatusService,
  //     type: ROSConstants.triggerServiceMsg,
  //     ros: _rosService.ros,
  //   );
  //   await service.call(requestData).then((response) {
  //     print("Service response: $response");
  //     if(response is Map<String, dynamic>) {
  //       var bootStatus = jsonDecode(response['message']);
  //       state = BootStatusResponse.fromJson(bootStatus);
  //     } else {
  //       BootStatusResponse error = BootStatusResponse(
  //         message: response,
  //       );
  //       state = error;
  //     }
  //   }).catchError((onError) {
  //     BootStatusResponse error = BootStatusResponse(
  //       message: onError.toString(),
  //     );
  //     state = error;
  //   });
  // }

  /*  For advertise purpose */
  // Future<Map<String, dynamic>>? serviceHandler(Map<String, dynamic> args) async {
  //   Map<String, dynamic> response = {};
  //   print("Service response: $response");
  //   // var bootStatus = jsonDecode(response['message']);
  //   state = BootStatusResponse.fromJson({});
  //   return response;
  // }

  void clearTopic() {
    _topic.unsubscribe();
  }

  @override
  void dispose() {
    _topic.unsubscribe();
    super.dispose();
  }
}

final bootCheckVMProvider = StateNotifierProvider.autoDispose<BootCheckViewModel, BootCheckResponse>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return BootCheckViewModel(rosService);
});
