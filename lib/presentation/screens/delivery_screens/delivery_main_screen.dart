import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alfred/providers/table_providers.dart';
import '../../../config/alfred_constants.dart';
import '../../widgets/appbar_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/training_table_widget.dart';

// Provider using int? for table numbers
final selectedTableProvider = StateNotifierProvider<SelectedTableNotifier, int?>((ref) {
  return SelectedTableNotifier();
});

class SelectedTableNotifier extends StateNotifier<int?> {
  SelectedTableNotifier() : super(null);

  void selectTable(int table) {
    state = table;
  }
}

class DeliveryMainScreen extends ConsumerWidget {
  const DeliveryMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tables = ref.watch(tableProvider);
    final selectedTable = ref.watch(selectedTableProvider);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AlfredAppBar(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sidebar
                    Padding(
                      padding: const EdgeInsets.only(left: 0, top: 70),
                      child: Container(
                        width: 63,
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/images/Edit_icon.svg',
                                width: 31,
                                height: 31,
                              ),
                              onPressed: () {},
                            ),
                            Center(
                              child: Text(
                                'Training \nMode',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.20,
                                  letterSpacing: 0.24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/images/setting_icon.svg',
                                width: 36,
                                height: 36,
                              ),
                              onPressed: () {},
                            ),
                            Text(
                              "Settings",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.20,
                                letterSpacing: 0.24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Left Section (Robot Image & Text)
                    Expanded(
                      flex: 2,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 183,
                            top: 50,
                            child: Text(
                              "Alfred at Base",
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            left: 111,
                            top: 100,
                            child: Text(
                              "Start the Service by selecting table number",
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            left: 122,
                            top: 218,
                            bottom: 5,
                            child: Image.asset(
                              "assets/images/alfred_base.png",
                              width: 267,
                              height: 614,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right Section (Table Selection)
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Select Tables",
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 49),
                            // Grid of Tables
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(right: 40),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 49,
                                  mainAxisSpacing: 26,
                                  childAspectRatio: 138 / 60,
                                ),
                                itemCount: tables.length,
                                itemBuilder: (context, index) {
                                  final currentSelection = ref.watch(selectedTableProvider);
                                  final isSelected = currentSelection == tables[index];

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      right: index % 4 == 3 ? 0 : 0,
                                    ),
                                    child: TableGridButton(
                                      label: tables[index].toString(),
                                      tableNumber: tables[index],
                                      isSelected: isSelected, // Now this will work
                                      onPressed: () {
                                        ref.read(selectedTableProvider.notifier).state =
                                        currentSelection == tables[index] ? null : tables[index];
                                      },
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // "Go to Table" Button
          // Bottom button matching table grid width (responsive)
          Positioned(
            left: 0,
            right: 40,
            bottom: 36,
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  // Left spacer matching table grid layout (flex:2)
                  const Expanded(
                    flex: 2,
                    child: SizedBox(),
                  ),
                  const SizedBox(width: 20), // Same gap as in table grid

                  // Button with adjusted width
                  Container(
                    width: MediaQuery.of(context).size.width * 0.53, // Reduced from 0.6 to 0.52
                    height: 80,
                    margin: const EdgeInsets.only(right: 20),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final selectedTable = ref.watch(selectedTableProvider);
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: selectedTable != null ? Colors.black : const Color(0xFFC4C4C4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 3,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: selectedTable != null
                                ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Going to Table $selectedTable'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              context.go(
                                '${AlfredConstants.routeDeliveryInProgressScreen}/$selectedTable',
                              );
                            }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                "Go to Table",
                                style: GoogleFonts.nunito(
                                  color: selectedTable != null ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


