import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rosbridge/core/ros.dart';

import '../src/core/providers/core_providers.dart';
import '../src/core/services/ros_service.dart';

enum ConnectionStatus { connecting, connected, error, closed }

class ROSConnectionViewModel extends StateNotifier<ConnectionStatus> {

  final ROSService _rosService;
  late final StreamSubscription _subscription;

  Timer? _retryTimer;

  ROSConnectionViewModel(this._rosService) : super(ConnectionStatus.connecting) {
    _subscription = _rosService.connectionStream.listen((status) {
      print(status.name);
      if (status == ROSConnectionStatus.connected) {
        state = ConnectionStatus.connected;
        _cancelRetry();
      } else {
        state = ConnectionStatus.connecting;
        _startRetry();
      }
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
    print('Cancelling ros connection retry');
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  @override
  void dispose() {
    print('Disposing ros connection');
    _subscription.cancel();
    _cancelRetry();
  }
}

final rosConnectionVMProvider = StateNotifierProvider<ROSConnectionViewModel, ConnectionStatus>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final rosConnectionVM = ROSConnectionViewModel(rosService);
  ref.onDispose(() => rosConnectionVM.dispose());
  return rosConnectionVM;
});
