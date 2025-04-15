
import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/models/trigger_state.dart';
import 'package:alfred/providers/ros_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/core/service.dart';

class BaseResetViewModel extends StateNotifier<TriggerResponse> {

  final ROSService _rosService;
  late Service service;

  Map<String, dynamic> requestData = {};

  BaseResetViewModel(this._rosService) : super(TriggerResponse());

  // Future<void> resetBasePoint() async {
  //   print('sending base rest command...');
  //   service = Service(
  //     name: ROSConstants.baseResetService,
  //     type: ROSConstants.triggerServiceMsg,
  //     ros: _rosService.ros,
  //   );
  //   await service.call(requestData).then((response) {
  //     print("Service response: $response");
  //     state = TriggerResponse.fromJson(response);
  //   }).catchError((onError) {
  //     print("onError: $onError");
  //     TriggerResponse error = TriggerResponse(
  //       message: onError.toString(),
  //     );
  //     state = error;
  //   });
  // }

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

final baseResetVMProvider = StateNotifierProvider<BaseResetViewModel, TriggerResponse>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return BaseResetViewModel(rosService);
});
