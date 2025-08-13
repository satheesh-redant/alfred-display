import 'dart:async';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/odom_state.dart';
import 'package:rosbridge/rosbridge.dart';

import '../src/core/providers/core_providers.dart';
import '../src/core/services/ros_service.dart';

class OdomViewModel extends StateNotifier<OdomState> {
  final ROSService _rosService;
  late final Topic odomTopic;

  OdomViewModel(this._rosService) : super(const OdomState()) {
    _initOdom();
  }

  void _initOdom() {
    odomTopic = _rosService.createTopic(
      ROSConstants.odomTopic,
      ROSConstants.odomTopicMsg,
      queueSize: 100,
      throttleRate: 0,
    );
    odomTopic.subscribe(_odomHandler);
  }

  Future<void> _odomHandler(Map<String, dynamic> message) async {
    state = state.copyWith(
      posX: message['pose']['pose']['position']['x'],
      posY: message['pose']['pose']['position']['y'],
      oriX: message['pose']['pose']['orientation']['x'],
      oriY: message['pose']['pose']['orientation']['y'],
      oriZ: message['pose']['pose']['orientation']['z'],
      oriW: message['pose']['pose']['orientation']['w'],
      linVel: message['twist']['twist']['linear']['x'],
      angVel: message['twist']['twist']['angular']['z'],
    );
  }

  @override
  void dispose() {
    odomTopic.unsubscribe();
    super.dispose();
  }
}

final odomVMProvider = StateNotifierProvider<OdomViewModel, OdomState>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return OdomViewModel(rosService);
});
