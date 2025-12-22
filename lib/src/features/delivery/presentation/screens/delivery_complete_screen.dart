import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/configs/alfred_constants.dart';
import '../../../../core/helpers/toast_utils.dart';
import '../../../../shared/widgets/appbar_widget.dart';
import '../../providers/delivery_providers.dart';
import '../../state/delivery_state.dart';
import '../../view_model/delivery_view_model.dart';

class DeliveryCompleteScreen extends ConsumerStatefulWidget {
  const DeliveryCompleteScreen({super.key});

  @override
  ConsumerState<DeliveryCompleteScreen> createState() =>
      _DeliveryCompleteScreenState();
}

class _DeliveryCompleteScreenState extends ConsumerState<DeliveryCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryViewModelProvider);
    final viewModel = ref.read(deliveryViewModelProvider.notifier);
    final screenWidth = MediaQuery.of(context).size.width;

    ref.listen(deliveryViewModelProvider, (previous, next) {
      if (next.state == DeliveryStatus.moving) {
        context.pushReplacement(AlfredConstants.routeDeliveryInProgressScreen);
        return;
      }
      if (next.state == DeliveryStatus.error) {
        showErrorToast(context: context, description: next.message);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      //appBar: const AppBarWidget (showBackButton: false),
      appBar:  AlfredAppBarWidget(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              deliveryState.selectedTable == 0
                  ? "Alfred is at Base"
                  : "Task completed at Table ${deliveryState.selectedTable}",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: screenWidth > 800
                  ? Row(
                children: [
                  // Left robot image
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 350,
                          child: Image.asset(
                            "assets/images/alfred_ready.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Table selection right panel
                  _buildTableSelectionCard(deliveryState, viewModel),
                ],
              )
                  : Column(
                children: [
                  SizedBox(
                    width: 150,
                    height: 250,
                    child: Image.asset(
                      "assets/images/alfred_ready.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildTableSelectionCard(deliveryState, viewModel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSelectionCard(DeliveryState deliveryState, DeliveryViewModel viewModel) {
    final availableTables = viewModel.availableTables;

    return Expanded(
      flex: 1,
      child: Card(
        elevation: 4,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 15, top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Select Destination heading
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "SELECT DESTINATION",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFB7185),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.8,
                        ),
                        itemCount: availableTables.length,
                        itemBuilder: (context, index) {
                          final tableNumber = availableTables[index];
                          final isSelected = tableNumber == deliveryState.selectedTable;

                          return GestureDetector(
                            onTap: () => viewModel.selectTable(
                                isSelected ? null : tableNumber),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFB7185).withOpacity(0.1)
                                    : Colors.grey.shade50,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFB7185) : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      tableNumber == 0 ? Icons.home : Icons.table_restaurant,
                                      size: 20,
                                      color: isSelected
                                          ? const Color(0xFFFB7185)
                                          : Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tableNumber == 0
                                          ? "Base"
                                          : tableNumber.toString(),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? const Color(0xFFFB7185)
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    if (deliveryState.selectedTable != null) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => viewModel.goToTable(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFB7185),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Go to ${deliveryState.selectedTable == 0 ? 'Base' : 'Table ${deliveryState.selectedTable}'}",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
