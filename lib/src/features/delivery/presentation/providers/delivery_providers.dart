import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/services/delivery_service.dart';
import '../../data/models/delivery_models.dart';
import '../view_models/delivery_main_view_model.dart';
import '../view_models/delivery_progress_view_model.dart';

final deliveryServiceProvider = Provider<DeliveryService>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final deliveryService = DeliveryService(rosService);
  ref.onDispose(() => deliveryService.dispose());
  return deliveryService;
});

final deliveryMainViewModelProvider = StateNotifierProvider<DeliveryMainViewModel, DeliveryData>((ref) {
  final deliveryService = ref.watch(deliveryServiceProvider);
  return DeliveryMainViewModel(deliveryService);
});

final deliveryProgressViewModelProvider = StateNotifierProvider<DeliveryProgressViewModel, DeliveryData>((ref) {
  final deliveryService = ref.watch(deliveryServiceProvider);
  return DeliveryProgressViewModel(deliveryService);
});