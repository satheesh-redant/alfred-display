import 'dart:async';
import 'package:alfred/config/ros_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ros_service.dart';
import 'package:rosbridge/rosbridge.dart';

class DeliveryViewModel extends StateNotifier<String> {
  final ROSService _rosService;
  Topic? _topicMoveTable, _topicDeliveryStatus;

  DeliveryViewModel(this._rosService) : super("") {
    print('initiating all delivery topics');
    _topicMoveTable = _rosService.createTopic(
      ROSConstants.topicMoveTable,
      ROSConstants.msgInteger,
    );

    _topicDeliveryStatus = _rosService.createTopic(
      ROSConstants.topicDeliveryStatus,
      ROSConstants.msgString,
      throttleRate: 500,
    );
    _topicDeliveryStatus!.subscribe(_handlerAck);
  }

  Future<void> moveTable({required int table}) async {
    Map<String, dynamic> json = {'data': table};
    print('Publishing move table: $json');
    await _topicMoveTable!.publish(json);
  }

  Future<void> _handlerAck(Map<String, dynamic> message) async {
    print('delivery status: $message');
    state = message['data'];
  }

  @override
  void dispose() {
    print('Disposing all delivery topics');
    _topicMoveTable!.unsubscribe();
    _topicDeliveryStatus!.unsubscribe();
    state = "";
  }
}

final deliveryVMProvider =
    StateNotifierProvider<DeliveryViewModel, String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final deliveryVM = DeliveryViewModel(rosService);
  ref.onDispose(() => deliveryVM.dispose());
  return deliveryVM;
});
