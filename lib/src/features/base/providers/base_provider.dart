import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ros_service.dart';

final rosServiceProvider = Provider<ROSService>((ref) {
  final service = ROSService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Connection status stream for UI listening
final rosConnectionStatusProvider = StreamProvider<ROSConnectionStatus>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return rosService.connectionStream;
});

// Current connection state (non-Stream) for direct access
final rosConnectionStateProvider = Provider<ROSConnectionStatus>((ref) {
  final connectionAsync = ref.watch(rosConnectionStatusProvider);
  return connectionAsync.when(
    data: (status) => status,
    loading: () => ROSConnectionStatus.connecting,
    error: (_, __) => ROSConnectionStatus.error,
  );
});

// Base reset acknowledgment stream (for BasePointViewModel)
final baseResetAckProvider = StreamProvider<String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return rosService.baseResetStatusStream;
});
