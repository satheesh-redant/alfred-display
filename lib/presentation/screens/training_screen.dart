import 'package:alfred/view_models/add_table_view_model.dart';
import 'package:alfred/view_models/base_point_view_model.dart';
import 'package:alfred/view_models/operation_view_model.dart';
import 'package:alfred/view_models/table_view_model.dart';
import 'package:flutter/material.dart';
import 'package:alfred/config/alfred_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alfred/providers/table_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../core/toast_utils.dart';
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
  bool showBasePointMessage = false;

  @override
  Widget build(BuildContext context) {
    final tables = ref.watch(tableProvider);
    final selectedTable = ref.watch(selectedTableProvider);
    final isMarkingComplete = ref.watch(isMarkingCompleteProvider);

    /*  Add Table Ack */
    ref.listen(
      addTableVMProvider,
      (previous, next) {
        if (next.isNotEmpty) {
          if (next == "Success") {
            ref.context.loaderOverlay.hide();
            ref.read(addTableVMProvider.notifier).unsubscribe();
            showSuccessToast(
                context: context,
                description: "Table $selectedTable marked successfully");
            setState(() {
              markedTables.add(selectedTable!);
              currentlyMarkedTable = selectedTable;
              showBasePointMessage = true;
            });
            ref.read(isMarkingCompleteProvider.notifier).state = true;
            ref.read(selectedTableProvider.notifier).state = null;
          } else {
            // showErrorToast(context: context, description: next);
          }
        }
      },
    );

    /*  Return to Base Ack  */
    ref.listen(
      basePointVMProvider,
      (previous, next) {
        if (next.isNotEmpty) {
          if (next == "Success") {
            ref.read(basePointVMProvider.notifier).removeReturnToBaseListener();
            ref.read(opsVMProvider.notifier).getCurrentOp();
            ref.read(opsVMProvider.notifier).sendOpsMode(mode: 'delivery');
          } else {
            ref.context.loaderOverlay.hide();
          }
        }
      },
    );

    /*  Current ops mode */
    ref.listen(
      opsVMProvider,
      (previous, next) {
        if (next == 'delivery') {
          ref.context.loaderOverlay.hide();
          ref.read(opsVMProvider.notifier).unsubscribe();
          context.go(AlfredConstants.routeDeliveryMainScreen);
        }
      },
    );

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
                                  margin:
                                      const EdgeInsets.only(top: 50, left: 63),
                                  alignment: Alignment.center,
                                  //todo: Dynamic text that changes based on marking state
                                  child: Text(
                                    showBasePointMessage
                                        ? 'You are at your Base Point, please move Alfred towards table to start marking'
                                        : 'Move Alfred manually, place it towards the table and click on Table Number',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      height: 24.2 / 18,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
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
                                      padding: const EdgeInsets.only(
                                          right: 60, bottom: 20),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 49,
                                        mainAxisSpacing: 26,
                                        childAspectRatio: 138 / 60,
                                      ),
                                      itemCount: tables.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index < tables.length) {
                                          final table = tables[index];
                                          final isMarked =
                                              markedTables.contains(table);
                                          final isSelected =
                                              currentlyMarkedTable == table;
                                          final isDisabled =
                                              isMarkingComplete && !isSelected;

                                          return TableGridButtonWidget(
                                            label: table.toString(),
                                            tableNumber: table,
                                            isSelected: isSelected,
                                            isDisabled: isDisabled || isMarked,
                                            isMarked: isMarked,
                                            onPressed: isDisabled || isMarked
                                                ? null
                                                : () {
                                                    ref
                                                        .read(
                                                            selectedTableProvider
                                                                .notifier)
                                                        .state = table;
                                                  },
                                          );
                                        } else {
                                          return AnimatedAddButtonWidget(
                                            isTraining: false,
                                            isDisabled: isMarkingComplete,
                                            onPressed: () => ref
                                                .read(tableProvider.notifier)
                                                .addTable(),
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
                //todo: Confirm button
                if (!isMarkingComplete)
                  ButtonWidget(
                    text: "Confirm",
                    onPressed: selectedTable != null
                        ? () {
                            ref.context.loaderOverlay.show();
                            ref.read(addTableVMProvider.notifier).addTableAck();
                            ref.read(addTableVMProvider.notifier).addTable(table: selectedTable);
                          }
                        : null,
                    isActive: selectedTable != null,
                    width: MediaQuery.of(context).size.width * 0.55,
                  ),
                //todo: Show action buttons when marking is complete
                if (isMarkingComplete)
                  Row(
                    children: [
                      ButtonWidget(
                        text: "Mark Next Table",
                        onPressed: () {
                          setState(() {
                            showBasePointMessage = false;
                            currentlyMarkedTable = null;
                          });
                          ref.read(isMarkingCompleteProvider.notifier).state =
                              false;
                        },
                        isActive: true,
                        width: MediaQuery.of(context).size.width * 0.25,
                      ),
                      SizedBox(width: 40),
                      ButtonWidget(
                        //todo: Button to return to base screen
                        text: "Return to Base",
                        onPressed: () {
                          ref.context.loaderOverlay.show();
                          ref.read(basePointVMProvider.notifier).getReturnToBaseAck();
                          ref.read(basePointVMProvider.notifier).triggerReturnToBase();
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
