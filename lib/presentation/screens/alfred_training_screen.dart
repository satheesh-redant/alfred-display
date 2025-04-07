
import 'package:flutter/material.dart';
import 'package:alfred/config/alfred_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alfred/providers/table_providers.dart';
import 'package:go_router/go_router.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/training_table_widget.dart';
import '../widgets/animated_add_button_widget.dart'; // Add this import

class AlfredTrainingScreen extends ConsumerWidget {
  const AlfredTrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tableProvider);
    final selectedTable = ref.watch(selectedTableProvider);
    final isTraining = ref.watch(isTrainingProvider);
    final scrollController = ScrollController();

    return Scaffold(
      appBar: AlfredAppBar(),
      body: Column(
        children: [
          // Main content area - made scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 150, // Account for appbar and button
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Section (Text + Image)
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.only(top: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 355,
                                  height: 49,
                                  margin: const EdgeInsets.only(top: 50, left: 63),
                                  alignment: Alignment.center,
                                  child: Text.rich(
                                    TextSpan(
                                      text: "Move Alfred manually, place it towards the table and click on ",
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400,
                                        height: 24.2 / 18,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Table Number",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            height: 24.2 / 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 60),
                                Image.asset(
                                  "assets/images/alfred_base.png",
                                  width: 450,
                                  height: 400,
                                  fit: BoxFit.contain,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Right Section (Table Buttons + Add Table)
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.only(top: 82),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mark Tables",
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.20,
                                  ),
                                ),
                                const SizedBox(height: 43),
                                SizedBox(
                                  height: 400,
                                  child: Scrollbar(
                                    controller: scrollController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    child: GridView.builder(
                                      controller: scrollController,
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.only(right: 60, bottom: 20),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 49,
                                        mainAxisSpacing: 26,
                                        childAspectRatio: 138 / 60,
                                      ),
                                      itemCount: tables.length + 1,

                                      // In your GridView.builder:
                                      itemBuilder: (context, index) {
                                        if (index < tables.length) {
                                          final isSelected = selectedTable == tables[index];
                                          final isDisabled = isTraining && !isSelected;

                                          return TableGridButton(
                                            label: tables[index].toString(),
                                            tableNumber: tables[index],
                                            isSelected: isSelected,
                                            isDisabled: isDisabled,
                                            onPressed: isDisabled
                                                ? null
                                                : () {
                                              ref.read(selectedTableProvider.notifier).state =
                                              isSelected ? null : tables[index];
                                            },
                                          );
                                        } else {
                                          return AnimatedAddButton(
                                            isTraining: isTraining,
                                            isDisabled: isTraining,
                                            onPressed: () => ref.read(tableProvider.notifier).addTable(),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom button with flex:3 width
          // Bottom button with adjusted width to match table grid
          Padding(
            padding: const EdgeInsets.only(bottom: 20, right: 70, left: 15),
            child: Row(
              children: [
                // Left spacer (flex:2 to match your layout)
                const Expanded(
                  flex: 2,
                  child: SizedBox(),
                ),
                const SizedBox(width: 20), // Same spacing as between your sections

                // Button with adjusted width
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55, // Reduced from 0.6 to 0.45
                  height: 80,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (isTraining) {
                            ref.read(isTrainingProvider.notifier).state = false;
                            context.pushReplacement(AlfredConstants.routeDeliveryMainScreen);
                          } else {
                            if (selectedTable != null) {
                              ref.read(isTrainingProvider.notifier).state = true;
                            } else {
                              context.pushReplacement(AlfredConstants.routeDeliveryMainScreen);
                            }
                          }
                        },
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              isTraining ? "Finish Training" : "Return to Base",
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                height: 24.2 / 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

