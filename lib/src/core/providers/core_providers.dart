import 'dart:async';
import 'package:alfred/src/core/base/base_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ros_service.dart';

// Main ROS service provider — creates and disposes ROSService
final rosServiceProvider = Provider<ROSService>((ref) {
  final service = ROSService();
  ref.onDispose(() => service.dispose());
  return service;
});

//  Connection states provider + retry logic like ViewModel (all in one)
final rosConnectionStateProvider = StreamProvider<ROSConnectionStatus>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return rosService.connectionStream;
});
