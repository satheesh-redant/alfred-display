
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/models/delivery_models.dart';
import '../view_models/delivery_view_model.dart';

final deliveryViewModelProvider =
StateNotifierProvider<DeliveryViewModel, DeliveryData>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  return DeliveryViewModel(rosService);
});
