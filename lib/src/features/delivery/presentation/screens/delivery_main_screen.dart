import 'package:alfred/config/alfred_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/delivery_models.dart';
import '../providers/delivery_providers.dart';
import '../view_models/delivery_main_view_model.dart';
import '../widgets/table_grid_widget.dart';
import '../widgets/delivery_action_button.dart';
import '../../../../shared/widgets/status_card_widget.dart';

class DeliveryMainScreen extends ConsumerWidget {
  const DeliveryMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryState = ref.watch(deliveryMainViewModelProvider);
    final viewModel = ref.read(deliveryMainViewModelProvider.notifier);

    ref.listen(deliveryMainViewModelProvider, (previous, next) {
      if (next.state == DeliveryState.moving) {
        context.push(AlfredConstants.routeDeliveryInProgressScreen);
      } else if (next.state == DeliveryState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Service'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusCardWidget(
              title: 'Alfred at Base',
              subtitle: deliveryState.selectedTable != null
                  ? 'Table ${deliveryState.selectedTable} selected'
                  : 'Start the service by selecting a table number',
              imagePath: 'assets/images/alfred_base.png',
            ),

            const SizedBox(height: 32),

            const Text(
              'Select Table',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _buildTableGrid(viewModel, deliveryState),
            ),

            DeliveryActionButton(
              text: 'Go to Table',
              isEnabled: deliveryState.selectedTable != null && deliveryState.state != DeliveryState.moving,
              isLoading: deliveryState.state == DeliveryState.moving,
              onPressed: () => viewModel.goToTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableGrid(DeliveryMainViewModel viewModel, DeliveryData deliveryState) {
    final availableTables = viewModel.availableTables;

    if (availableTables.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading available tables...'),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2,
      ),
      itemCount: availableTables.length,
      itemBuilder: (context, index) {
        final tableNumber = availableTables[index];
        final isSelected = deliveryState.selectedTable == tableNumber;

        return TableGridWidget(
          tableNumber: tableNumber,
          isSelected: isSelected,
          onTap: () => viewModel.selectTable(isSelected ? null : tableNumber),
        );
      },
    );
  }
}