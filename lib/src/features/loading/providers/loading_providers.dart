import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/core_providers.dart';
//import '../../base/providers/base_provider.dart';
import '../states/loading_screen_state.dart';
import '../view_models/loading_screen_view_model.dart';
import '../../../core/services/ros_service.dart';

// BootCheckService → now handled inside ROSService
final bootCheckServiceProvider = Provider<ROSService>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return rosService;                       // return ROSService instead of BootCheckService
});

// OperationModeService → now handled inside ROSService
final operationsServiceProvider = Provider<ROSService>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return rosService;                       // return ROSService instead of OperationModeService
});

// ViewModel Provider
final loadingScreenViewModelProvider =
StateNotifierProvider<LoadingScreenViewModel, LoadingScreenState>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final bootCheckService = ref.watch(bootCheckServiceProvider);
  final operationsService = ref.watch(operationsServiceProvider);

  return LoadingScreenViewModel(
    rosService
  );
});

// // Global operation mode provider for other screens
// final currentOperationModeProvider = StreamProvider<OperationMode>((ref) {
//   final operationsService = ref.watch(operationsServiceProvider);
//   return operationsService.opsModeStream;  // from ROSService
// });
// Expose only the operation mode string to other screens
final currentOperationModeProvider = Provider<AsyncValue<String>>((ref) {
  final loadingState = ref.watch(loadingScreenViewModelProvider);
  return AsyncValue.data(loadingState.statusMessage);
});

