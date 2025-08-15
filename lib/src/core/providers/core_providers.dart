import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ros_service.dart';

final rosServiceProvider = Provider<ROSService>((ref) {
  final service = ROSService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Additional providers for reactive UI updates
final rosConnectionStatusProvider = StreamProvider<ROSConnectionStatus>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return rosService.connectionStream;
});

final rosConnectionStateProvider = Provider<ROSConnectionStatus>((ref) {
  final connectionAsync = ref.watch(rosConnectionStatusProvider);
  return connectionAsync.when(
    data: (status) => status,
    loading: () => ROSConnectionStatus.connecting,
    error: (_, __) => ROSConnectionStatus.error,
  );
});
