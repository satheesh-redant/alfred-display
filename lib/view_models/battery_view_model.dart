import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/models/battery_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class BatteryViewModel extends StateNotifier<BatteryStatus> {
  final ROSService _rosService;
  late final Topic _topic;

  BatteryViewModel(this._rosService) : super(BatteryStatus()) {
    init();
  }

  void init() {
    _topic = _rosService.createTopic(
      ROSConstants.topicBattery,
      ROSConstants.msgString,
    );
    _topic.subscribe(_handler);
  }

  Future<void> _handler(Map<String, dynamic> message) async {
    print(message);
    var batteryStatus = jsonDecode(message['data']);
    state = BatteryStatus.fromJson(batteryStatus);
  }

  @override
  void dispose() {
    _topic.unsubscribe();
    super.dispose();
  }
}

final batteryVMProvider = StateNotifierProvider<BatteryViewModel, BatteryStatus>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return BatteryViewModel(rosService);
});
