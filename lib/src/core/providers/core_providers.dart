// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/ros_service.dart';
//
// final rosServiceProvider = Provider<ROSService>((ref) {
//   final service = ROSService();
//   ref.onDispose(() => service.dispose());
//   return service;
// });
//
// // Additional providers for reactive UI updates
// final rosConnectionStatusProvider = StreamProvider<ROSConnectionStatus>((ref) {
//   final rosService = ref.watch(rosServiceProvider);
//   return rosService.connectionStream;
// });
//
// final rosConnectionStateProvider = Provider<ROSConnectionStatus>((ref) {
//   final connectionAsync = ref.watch(rosConnectionStatusProvider);
//   return connectionAsync.when(
//     data: (status) => status,
//     loading: () => ROSConnectionStatus.connecting,
//     error: (_, __) => ROSConnectionStatus.error,
//   );
// });


// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../services/ros_service.dart';
//
// // Main ROS service provider — creates and disposes ROSService
// final rosServiceProvider = Provider<ROSService>((ref) {
//   final service = ROSService();
//   ref.onDispose(() => service.dispose());
//   return service;
// });
//
// // Starts ROS connection (call this once, for example in initState)
// final rosConnectProvider = Provider<void>((ref) {
//   final rosService = ref.read(rosServiceProvider);
//   rosService.connect();
// });
//
// // Stream provider that listens to ROS connection status updates
// final rosConnectionStatusProvider = StreamProvider<ROSConnectionStatus>((ref) {
//   final rosService = ref.watch(rosServiceProvider);
//   return rosService.connectionStream;
// });
//
// // Always gives a non-Async connection state (safe for UI)
// final rosConnectionStateProvider = Provider<ROSConnectionStatus>((ref) {
//   final asyncStatus = ref.watch(rosConnectionStatusProvider);
//   return asyncStatus.when(
//     data: (status) => status,
//     loading: () => ROSConnectionStatus.connecting,
//     error: (_, __) => ROSConnectionStatus.error,
//   );
// });


import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ros_service.dart';

// Main ROS service provider — creates and disposes ROSService
final rosServiceProvider = Provider<ROSService>((ref) {
  final service = ROSService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Starts ROS connection (call this once)
final rosConnectProvider = Provider<void>((ref) {
  final rosService = ref.read(rosServiceProvider);
  rosService.connect();
});

//  Connection state provider + retry logic like ViewModel (all in one)
final rosConnectionStateProvider =
StateNotifierProvider<_ROSConnectionNotifier, ROSConnectionStatus>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final notifier = _ROSConnectionNotifier(rosService);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

//  internal notifier class (NOT a separate file, inside same code)
class _ROSConnectionNotifier extends StateNotifier<ROSConnectionStatus> {
  final ROSService _rosService;
  late final StreamSubscription _sub;
  Timer? _retryTimer;

  _ROSConnectionNotifier(this._rosService)
      : super(ROSConnectionStatus.connecting) {
    _sub = _rosService.connectionStream.listen((status) {
      if (status == ROSConnectionStatus.connected) {
        state = ROSConnectionStatus.connected;
        _cancelRetry();
      } else {
        state = ROSConnectionStatus.connecting;
        _startRetry();
      }
    });
  }

  void _startRetry() {
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
    _sub.cancel();
    _cancelRetry();
    super.dispose();
  }
}
