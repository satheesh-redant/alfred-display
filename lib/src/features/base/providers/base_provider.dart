import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/ros_service.dart';

final baseResetAckProvider = StreamProvider<String>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return rosService.baseResetStatusStream;
});
