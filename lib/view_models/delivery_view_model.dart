import 'dart:async';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ros_service_provider.dart';
import 'package:rosbridge/rosbridge.dart';

class DeliveryViewModel extends StateNotifier<String> {

  final ROSService _rosService;
  Topic? _topicMoveTable, _topicDeliveryStatus;

  DeliveryViewModel(this._rosService) : super("");

  Future<void> moveTable({required int table}) async {
    print('initiating move table topic...');
    _topicMoveTable = _rosService.createTopic(
      ROSConstants.topicMoveTable,
      ROSConstants.msgString,
    );

    _topicMoveTable!.subscribe((msg) async {
      print("Received echo on trigger topic: $msg");
      _topicMoveTable!.unsubscribe();
    });

    Map<String, dynamic> json = {"data": table.toString()};
    await _topicMoveTable!.publish(json);

    Timer(const Duration(seconds: 1), () {
      state = "moving";
    });

    Timer(const Duration(seconds: 5), () {
      state = "delivered";
    });
  }

  Future<void> deliveryStatus() async {
    print('initiating delivery status topic...');
    _topicDeliveryStatus = _rosService.createTopic(
      ROSConstants.topicDeliveryStatus,
      ROSConstants.msgString,
      throttleRate: 500,
    );

    _topicDeliveryStatus!.subscribe(_handlerAck);
  }

  Future<void> _handlerAck(Map<String, dynamic> message) async {
    print(message);
    state = message['data'];
  }

  void unsubscribe() {
    _topicDeliveryStatus!.unsubscribe();
    state = "";
  }

}

final deliveryVMProvider = StateNotifierProvider<DeliveryViewModel, String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return DeliveryViewModel(rosService);
});
