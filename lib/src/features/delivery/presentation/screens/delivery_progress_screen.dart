import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/delivery_models.dart';
import '../providers/delivery_providers.dart';
import '../view_models/delivery_progress_view_model.dart';
import '../widgets/delivery_status_widget.dart';
import '../widgets/delivery_action_button.dart';

class DeliveryProgressScreen extends ConsumerWidget {
  final int? tableNumber;
  final int? route;

  const DeliveryProgressScreen({
    super.key,
    this.tableNumber,
    this.route,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(deliveryProgressViewModelProvider);
    final viewModel = ref.read(deliveryProgressViewModelProvider.notifier);

    ref.listen(deliveryProgressViewModelProvider, (previous, next) {
      // When table to base journey is completed, return to main screen
      if (next.progressStage == DeliveryProgressStage.tableToBaseFinished) {
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            context.pop();
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle(deliveryState.progressStage)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Message
              Text(
                deliveryState.message,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Status Widget with Image
              DeliveryStatusWidget(
                progressStage: deliveryState.progressStage,
                deliveryState: deliveryState.state,
              ),

              const SizedBox(height: 32),

              // Conditional Button based on stage
              _buildActionButton(deliveryState, viewModel),
            ],
          ),
        ),
      ),
    );
  }

  String _getScreenTitle(DeliveryProgressStage stage) {
    switch (stage) {
      case DeliveryProgressStage.baseToTable:
        return 'Going to Table';
      case DeliveryProgressStage.baseToTableFinished:
        return 'Arrived at Table';
      case DeliveryProgressStage.tableToBase:
        return 'Returning to Base';
      case DeliveryProgressStage.tableToBaseFinished:
        return 'Back at Base';
    }
  }

  Widget _buildActionButton(DeliveryData deliveryState, DeliveryProgressViewModel viewModel) {
    // Only show button when arrived at table (baseToTableFinished)
    if (deliveryState.progressStage == DeliveryProgressStage.baseToTableFinished) {
      return DeliveryActionButton(
        text: 'Return to Base',
        isEnabled: true,
        onPressed: () => viewModel.startReturnJourney(),
      );
    }

    return const SizedBox.shrink(); // Empty widget for other states
  }
}
