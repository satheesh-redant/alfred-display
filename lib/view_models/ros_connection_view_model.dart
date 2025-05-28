import 'dart:async';
import 'package:alfred/providers/ros_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/core/ros.dart';

enum ConnectionStatus { connecting, connected, error, closed }

class ROSConnectionViewModel extends StateNotifier<ConnectionStatus> {

  final ROSService _rosService;
  late final StreamSubscription _subscription;

  Timer? _retryTimer;

  ROSConnectionViewModel(this._rosService) : super(ConnectionStatus.connecting) {
    // Listen to the ROS connection status stream.
    _subscription = _rosService.ros.statusStream.listen((status) {
      print(status.name);
      // Adjust these conditions based on your actual ROS status values.
      if (status == Status.connected) {
        // 1. Mark connected
        state = ConnectionStatus.connected;
        // 2. Stop retrying
        _cancelRetry();
      } else {
        // Anything else -> stay in "connecting"
        state = ConnectionStatus.connecting;
        // And retry every 30s
        _startRetry();
      }
      /*if (status == Status.connected) {
        state = ConnectionStatus.connected;
      } else if (status == Status.errored) {
        state = ConnectionStatus.error;
      } else if (status == Status.closed) {
        state = ConnectionStatus.closed;
      } else {
        state = ConnectionStatus.connecting;
      }*/
    });
  }

  void connect() {
    state = ConnectionStatus.connecting;
    _rosService.connect();
  }

  void _startRetry() {
    // if there's already a live timer, no need to start another
    if (_retryTimer?.isActive ?? false) return;
    _retryTimer = Timer.periodic(
      const Duration(seconds: 30),
          (_) => _rosService.connect(),
    );
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  @override
  void dispose() {
    _subscription.cancel();
    _cancelRetry();
    super.dispose();
  }
}

final rosConnectionVMProvider = StateNotifierProvider<ROSConnectionViewModel, ConnectionStatus>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return ROSConnectionViewModel(rosService);
});
