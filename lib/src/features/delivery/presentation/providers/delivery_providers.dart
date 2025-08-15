import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../shared/services/delivery_service.dart';
import '../../data/models/delivery_models.dart';
import '../view_models/delivery_view_model.dart';

final deliveryServiceProvider = Provider<DeliveryService>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final deliveryService = DeliveryService(rosService);
  ref.onDispose(() => deliveryService.dispose());
  return deliveryService;
});

final deliveryViewModelProvider = StateNotifierProvider<DeliveryViewModel, DeliveryData>((ref) {
  final deliveryService = ref.watch(deliveryServiceProvider);
  return DeliveryViewModel(deliveryService);
});
