import 'dart:async';
import 'dart:ffi';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class BatteryViewModel extends StateNotifier<Float> {
  final ROSService _rosService;
  late final Topic _topic;

  BatteryViewModel(this._rosService) : super(const Float()) {
    init();
  }

  void init() {
    _topic = _rosService.createTopic(
      ROSConstants.topicBattery,
      ROSConstants.msgFloat,
    );
    _topic.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print(message);
    //todo handle the response
    // state = state.copyWith(
    //   posX: message['pose']['pose']['position']['x'],
    //   posY: message['pose']['pose']['position']['y'],
    //   oriX: message['pose']['pose']['orientation']['x'],
    //   oriY: message['pose']['pose']['orientation']['y'],
    //   oriZ: message['pose']['pose']['orientation']['z'],
    //   oriW: message['pose']['pose']['orientation']['w'],
    //   linVel: message['twist']['twist']['linear']['x'],
    //   angVel: message['twist']['twist']['angular']['z'],
    // );
  }

  @override
  void dispose() {
    _topic.unsubscribe();
    super.dispose();
  }
}

final batteryVMProvider = StateNotifierProvider<BatteryViewModel, Float>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return BatteryViewModel(rosService);
});
