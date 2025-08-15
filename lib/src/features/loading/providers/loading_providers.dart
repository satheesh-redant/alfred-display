import 'package:alfred/src/shared/services/operation_mode_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
import '../../../shared/services/boot_check_service.dart';
import '../states/loading_screen_state.dart';
import '../view_models/loading_screen_view_model.dart';

// Service Providers
final bootCheckServiceProvider = Provider<BootCheckService>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return BootCheckService(rosService);
});

final operationsServiceProvider = Provider<OperationModeService>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final service = OperationModeService(rosService);
  ref.onDispose(() => service.dispose());
  return service;
});

// ViewModel Provider
final loadingScreenViewModelProvider =
StateNotifierProvider<LoadingScreenViewModel, LoadingScreenState>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final bootCheckService = ref.watch(bootCheckServiceProvider);
  final operationsService = ref.watch(operationsServiceProvider);

  return LoadingScreenViewModel(
    rosService,
    bootCheckService,
    operationsService,
  );
});

// Global operation mode provider for other screens
final currentOperationModeProvider = StreamProvider<OperationMode>((ref) {
  final operationsService = ref.watch(operationsServiceProvider);
  return operationsService.operationStream;
});
