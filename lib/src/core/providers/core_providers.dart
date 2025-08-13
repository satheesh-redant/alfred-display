import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ros_service.dart';

final rosServiceProvider = Provider<ROSService>((ref) {
  final service = ROSService();
  ref.onDispose(() => service.dispose());
  return service;
});
