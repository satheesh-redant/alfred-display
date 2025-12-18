import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';
import '../data/mapping_repo.dart';
import '../states/mapping_state.dart';
import '../view_model/mapping_view_model.dart';

final mappingRepositoryProvider = Provider<MappingRepository>((ref) {
  final rosService = ref.watch(rosServiceProvider);
  final repo = MappingRepository(rosService);
  ref.onDispose(repo.dispose);
  return repo;
});

final mappingVMProvider =
StateNotifierProvider.autoDispose<MappingViewModel, MappingState>((ref) {
  final repo = ref.watch(mappingRepositoryProvider);
  final vm = MappingViewModel(repo);
  ref.onDispose(vm.dispose);
  return vm;
});