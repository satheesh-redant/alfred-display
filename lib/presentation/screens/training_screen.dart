import 'package:flutter/material.dart';
import 'package:alfred/config/alfred_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alfred/providers/table_providers.dart';
import 'package:go_router/go_router.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/table_grid_button_widget.dart';
import '../widgets/animated_add_button_widget.dart';
import '../widgets/button_widget.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  final scrollController = ScrollController();
  List<int> markedTables = [];
  int? currentlyMarkedTable;

  @override
  Widget build(BuildContext context) {
    final tables = ref.watch(tableProvider);
    final selectedTable = ref.watch(selectedTableProvider);
    final isMarkingComplete = ref.watch(isMarkingCompleteProvider);

    return Scaffold(
      appBar: AppBarWidget(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 150,
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                      itemBuilder: (context, index) {
                                        if (index < tables.length) {
                                          final table = tables[index];
                                          final isMarked = markedTables.contains(table);
                                          final isSelected = currentlyMarkedTable == table;
                                          final isDisabled = isMarkingComplete && !isSelected;

                                          return TableGridButtonWidget(
                                            label: table.toString(),
                                            tableNumber: table,
                                            isSelected: isSelected,
                                            isDisabled: isDisabled || isMarked,
                                            isMarked: isMarked,
                                            onPressed: isDisabled || isMarked
                                                ? null
                                                : () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Table $table selected'),
                                                  duration: Duration(seconds: 1),
                                                ),
                                              );
                                              ref.read(selectedTableProvider.notifier).state = table;
                                            },
                                          );
                                        } else {
                                          return AnimatedAddButtonWidget(
                                            isTraining: false,
                                            isDisabled: isMarkingComplete,
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
          Padding(
            padding: const EdgeInsets.only(bottom: 20, right: 70, left: 15),
            child: Row(
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                const SizedBox(width: 20),
                if (!isMarkingComplete)
                  ButtonWidget(
                    text: "Confirm",
                    onPressed: selectedTable != null
                        ? () {
                      setState(() {
                        markedTables.add(selectedTable);
                        currentlyMarkedTable = selectedTable;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Table $selectedTable marked successfully!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      ref.read(isMarkingCompleteProvider.notifier).state = true;
                      ref.read(selectedTableProvider.notifier).state = null;
                    }
                        : null,
                    isActive: selectedTable != null,
                    width: MediaQuery.of(context).size.width * 0.55,
                  ),
                if (isMarkingComplete)
                  Row(
                    children: [
                      ButtonWidget(
                        text: "Mark Next Table",
                        onPressed: () {
                          ref.read(isMarkingCompleteProvider.notifier).state = false;
                          setState(() {
                            currentlyMarkedTable = null;
                          });
                        },
                        isActive: true,
                        width: MediaQuery.of(context).size.width * 0.25,
                      ),
                      SizedBox(width: 10),
                      ButtonWidget(
                        text: "Return to Base",
                        onPressed: () {
                          context.pushReplacement(AlfredConstants.routeDeliveryMainScreen);
                        },
                        isActive: true,
                        width: MediaQuery.of(context).size.width * 0.25,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
