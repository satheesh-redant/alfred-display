import 'dart:async';
import 'package:alfred/providers/ros_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/core/ros.dart';

enum ConnectionStatus { connecting, connected, error, closed }

class ROSConnectionViewModel extends StateNotifier<ConnectionStatus> {

  final ROSService _rosService;
  late final StreamSubscription _subscription;

  ROSConnectionViewModel(this._rosService) : super(ConnectionStatus.connecting) {
    // Listen to the ROS connection status stream.
    _subscription = _rosService.ros.statusStream.listen((status) {
      print(status.name);
      // Adjust these conditions based on your actual ROS status values.
      if (status == Status.connected) {
        state = ConnectionStatus.connected;
      } else if (status == Status.errored) {
        state = ConnectionStatus.error;
      } else if (status == Status.closed) {
        state = ConnectionStatus.closed;
      } else {
        state = ConnectionStatus.connecting;
      }
    });
  }

  void connect() {
    _rosService.connect();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final rosConnectionVMProvider = StateNotifierProvider<ROSConnectionViewModel, ConnectionStatus>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return ROSConnectionViewModel(rosService);
});
