import 'package:alfred/src/core/configs/alfred_constants.dart';
import 'package:alfred/src/features/delivery/state/delivery_state.dart';
import 'package:alfred/src/shared/states/system_state.dart';
import 'package:alfred/src/shared/view_models/system_view_model.dart';
import 'package:alfred/src/shared/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../../../shared/models/operation_mode.dart';
import '../../../../shared/providers/system_provider.dart';
import '../../providers/delivery_providers.dart';
import '../widgets/delivery_completed_view.dart';
import '../widgets/delivery_progress_view.dart';
import '../widgets/error_view.dart';
import '../widgets/table_selection_view.dart';

class DeliveryScreen extends ConsumerStatefulWidget {
  const DeliveryScreen({super.key});

  @override
  ConsumerState<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen> {
  final ScrollController _gridScrollController = ScrollController();

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch system state
    final systemState = ref.watch(systemViewModelProvider);
    final systemVM = ref.read(systemViewModelProvider.notifier);

    // Watch delivery state
    final deliveryState = ref.watch(deliveryViewModelProvider);

    // Handle system loading overlay
    ref.listen(systemViewModelProvider, (previous, next) {
      if (previous?.statusMessage != next.statusMessage &&
          next.statusMessage.isNotEmpty) {
        print(next.statusMessage);
      }

      if (next.isLoading) {
        context.loaderOverlay.show();
      } else {
        context.loaderOverlay.hide();
      }

      if (next.powerStatus != null && next.powerStatus!.isShuttingDown) {
        context.go(AlfredConstants.routeSoftShutdownScreen);
      }

      if (next.currentMode == OperationMode.mapping) {
        context.go(AlfredConstants.routeMappingScreen);
      }
    });

    // Handle delivery loading
    ref.listen(deliveryViewModelProvider, (previous, next) {
      if (next.message.isNotEmpty) {
        print(next.message);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AlfredAppBarWidget(),
      body: _buildBody(systemState, systemVM, deliveryState),
    );
  }

  Widget _buildBody(SystemState systemState, SystemViewModel systemVM,
      DeliveryState deliveryState) {
    // State-driven UI rendering
    switch (deliveryState.status) {
      case DeliveryStatus.idle:
        return TableSelectionView(
          systemState: systemState,
          deliveryState: deliveryState,
        );

      case DeliveryStatus.moving:
        return DeliveryProgressView(
          deliveryState: deliveryState,
        );

      case DeliveryStatus.delivered:
        return DeliveryCompletedView(
          systemState: systemState,
          deliveryState: deliveryState,
        );

      case DeliveryStatus.error:
        return ErrorView(
          message: deliveryState.message,
          onRetry: () => ref.read(deliveryViewModelProvider.notifier).reset(),
        );
    }
  }
}
