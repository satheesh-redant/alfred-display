import 'package:flutter/material.dart';
import 'package:alfred/config/alfred_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alfred/providers/table_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart'; // keep this import
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
  //todo: Controller for managing scroll behavior of the table grid
  final scrollController = ScrollController();

  //todo: List to keep track of all marked tables
  List<int> markedTables = [];

  //todo: Currently marked table reference
  int? currentlyMarkedTable;

  //todo: Flag to toggle between instruction messages
  bool showBasePointMessage = false;

  @override
  Widget build(BuildContext context) {

    //todo: Get current list of tables from provider
    final tables = ref.watch(tableProvider);

    //todo: Get currently selected table from provider
    final selectedTable = ref.watch(selectedTableProvider);

    //todo: Check if marking process is complete
    final isMarkingComplete = ref.watch(isMarkingCompleteProvider);

    return Scaffold(
      appBar: AppBarWidget(),
      body: Column(
        children: [
          //todo: Main content area with scrollable table grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 150,
                ),
                child: Column(
                  children: [
                    //todo: Row containing instruction panel and table grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //todo: Left panel with instructions and image
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
                                //todo: Alfred base image display
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
                        //todo: Right panel with table grid
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
                                    //todo: Grid view for displaying tables
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
                                      //todo: Builder for table grid items
                                      itemBuilder: (context, index) {
                                        if (index < tables.length) {
                                          final table = tables[index];
                                          //todo: Check if table is marked
                                          final isMarked = markedTables.contains(table);
                                          //todo: Check if table is currently selected
                                          final isSelected = currentlyMarkedTable == table;
                                          //todo: Check if table should be disabled
                                          final isDisabled = isMarkingComplete && !isSelected;

                                          //todo: Return table button widget
                                          return TableGridButtonWidget(
                                            label: table.toString(),
                                            tableNumber: table,
                                            isSelected: isSelected,
                                            isDisabled: isDisabled || isMarked,
                                            isMarked: isMarked,
                                            onPressed: isDisabled || isMarked
                                                ? null
                                                : () {
                                              ref.read(selectedTableProvider.notifier).state = table;
                                            },
                                          );
                                        } else {
                                          //todo: Return "Add Table" button
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
          //todo: Bottom buttons panel
          Padding(
            padding: const EdgeInsets.only(bottom: 20, right: 70, left: 15),
            child: Row(
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                const SizedBox(width: 20),
                //todo: Show Confirm button when not in marking complete state
                if (!isMarkingComplete)
                  ButtonWidget(
                    text: "Confirm",
                    onPressed: selectedTable != null
                        ? () {
                      //todo: Mark table as completed
                      setState(() {
                        markedTables.add(selectedTable);
                        currentlyMarkedTable = selectedTable;
                        showBasePointMessage = true;
                      });

                      // ✅ Only toast shown
                      toastification.show(
                        context: context,
                        type: ToastificationType.success,
                        style: ToastificationStyle.fillColored,
                        title: Text("Success!"),
                        description: Text("Table $selectedTable marked successfully!"),
                        alignment: Alignment.bottomCenter,
                        autoCloseDuration: const Duration(seconds: 2),
                        animationBuilder: (context, animation, alignment, child) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: highModeShadow,
                        showProgressBar: true,
                        pauseOnHover: false,
                      );

                      //todo: Update marking complete state
                      ref.read(isMarkingCompleteProvider.notifier).state = true;
                      ref.read(selectedTableProvider.notifier).state = null;
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
                        //todo: Button to mark next table
                        text: "Mark Next Table",
                        onPressed: () {
                          setState(() {
                            showBasePointMessage = false;
                            currentlyMarkedTable = null;
                          });
                          //todo: Reset marking complete state
                          ref.read(isMarkingCompleteProvider.notifier).state = false;
                        },
                        isActive: true,
                        width: MediaQuery.of(context).size.width * 0.25,
                      ),
                      SizedBox(width: 40),
                      ButtonWidget(
                        //todo: Button to return to base screen
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



