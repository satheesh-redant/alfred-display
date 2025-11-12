import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../config/alfred_constants.dart';
import '../../../core/toast_utils.dart';
import '../../../models/route_state.dart';
import '../../../view_models/delivery_view_model.dart';
import '../../widgets/widget_appbar.dart';
import 'delivery_main_screen.dart';

class DeliveryCompleteScreen extends ConsumerStatefulWidget {
  const DeliveryCompleteScreen({super.key});

  @override
  ConsumerState<DeliveryCompleteScreen> createState() =>
      _DeliveryCompleteScreenState();
}

class _DeliveryCompleteScreenState
    extends ConsumerState<DeliveryCompleteScreen> {
  int? selectedTableNumber;

  // Generate available tables (excluding current location)
  List<int> get availableTables {
    final selectedTable = ref.watch(deliveryScreenTableProvider);
    if (selectedTable?.status == Status.completed) {
      List<int> tables = List.generate(11, (index) => index); // 0-10
      // Remove current table location
      tables.removeWhere((table) => table == selectedTable!.tableNumber);
      return tables;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final selectedTable = ref.watch(deliveryScreenTableProvider);

    ref.listen(
      deliveryVMProvider,
          (previous, next) {
        if (next.toLowerCase() == "moving") {
          ref.read(deliveryScreenTableProvider.notifier).state =
              RouteState(tableNumber: selectedTableNumber!, status: Status.inprogress);

          context
              .pushReplacement(AlfredConstants.routeDeliveryInProgressScreen);
        } else {
          showErrorToast(context: context, description: next);
        }
      },
    );

    return Scaffold(
      body: Column(
        children: [
          AlfredAppBarWidget(),

          // Task Completed Text - Top Center
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              selectedTable?.status == Status.completed
                  ? selectedTable?.tableNumber == 0
                      ? "Alfred is at Base"
                      : "Task completed at Table ${selectedTable?.tableNumber}"
                  : "",
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),

          // Main Content Area - Robot Left, Grid Right
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: screenWidth > 800
                  ? Row(
                      children: [
                        // Left Side - Robot Image
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

                        // Right Side - Table Selection Card
                        _buildTableSelectionCard(),
                      ],
                    )
                  : Column(
                      children: [
                        // Mobile Layout - Stack vertically
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
                          child: _buildTableSelectionCard(),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSelectionCard() {
    return Expanded(
      flex: 1,
      child: Card(
        elevation: 4,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        // Prevents Material 3 tint color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, bottom: 15, top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    // Grid for tables
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.8,
                        ),
                        itemCount: availableTables.length,
                        itemBuilder: (context, index) {
                          final tableNumber = availableTables[index];
                          final isSelected = selectedTableNumber == tableNumber;

                          return _buildTableButton(
                            tableNumber: tableNumber,
                            isSelected: isSelected,
                            onPressed: () {
                              setState(() {
                                selectedTableNumber = tableNumber;
                              });
                            },
                          );
                        },
                      ),
                    ),

                    // Action Button inside the card
                    if (selectedTableNumber != null) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(deliveryVMProvider.notifier).moveTable(
                                table: selectedTableNumber!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFB7185),
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Go to ${selectedTableNumber == 0 ? 'Base' : 'Table $selectedTableNumber'}",
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

  Widget _buildTableButton({
    required int tableNumber,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
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
                color:
                    isSelected ? const Color(0xFFFB7185) : Colors.grey.shade600,
              ),
              const SizedBox(height: 4),
              Text(
                tableNumber == 0 ? "Base" : tableNumber.toString(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFFFB7185) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
