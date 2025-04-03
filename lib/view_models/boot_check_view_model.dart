
import 'dart:convert';

import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/models/boot_status_state.dart';
import 'package:alfred/providers/ros_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/core/service.dart';

class BootCheckViewModel extends StateNotifier<BootStatusResponse> {

  final ROSService _rosService;
  late Service service;

  Map<String, dynamic> requestData = {};

  BootCheckViewModel(this._rosService) : super(BootStatusResponse());

  Future<void> init() async {
    print('Initializing boot status check...');
    service = Service(
      name: ROSConstants.bootStatusService,
      type: ROSConstants.bootStatusServiceMsg,
      ros: _rosService.ros,
    );
    await service.call(requestData).then((response) {
      print("Service response: $response");
      if(response is Map<String, dynamic>) {
        var bootStatus = jsonDecode(response['message']);
        state = BootStatusResponse.fromJson(bootStatus);
      } else {
        BootStatusResponse error = BootStatusResponse(
          message: response,
        );
        state = error;
      }
    }).catchError((onError) {
      BootStatusResponse error = BootStatusResponse(
        message: onError.toString(),
      );
      state = error;
    });
  }

  /*  For advertise purpose */
  // Future<Map<String, dynamic>>? serviceHandler(Map<String, dynamic> args) async {
  //   Map<String, dynamic> response = {};
  //   print("Service response: $response");
  //   var bootStatus = jsonDecode(response['message']);
  //   state = BootStatusResponse.fromJson(bootStatus);
  //   return response;
  // }

  @override
  void dispose() {
    service.unadvertise();
    super.dispose();
  }

}

final bootCheckVMProvider = StateNotifierProvider<BootCheckViewModel, BootStatusResponse>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return BootCheckViewModel(rosService);
});
