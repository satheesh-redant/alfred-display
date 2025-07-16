// lib/presentation/screens/training_screen.dart
import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/view_models/base_point_view_model.dart';
import 'package:alfred/view_models/operation_view_model.dart';
import 'package:alfred/view_models/table_view_model.dart';
import 'package:alfred/view_models/add_table_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../config/ros_constants.dart';
import '../../core/toast_utils.dart';
import '../../models/table_state.dart';
import '../widgets/add_table_dialog_widget.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/dialog_widget.dart';
import '../widgets/remove_table_button_widget.dart';
import '../widgets/table_grid_button_widget.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  final scrollController = ScrollController();
  final TextEditingController _tableNumberController = TextEditingController();
  bool _isDialogShowing = false;
  bool showBasePointMessage = false;

  @override
  void initState() {
    super.initState();
    ref.read(addTableVMProvider.notifier).addTableAck();
    ref.read(tableVMProvider.notifier).requestTableList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(tableVMProvider.notifier).hasMarkedTables &&
          ref.read(opsVMProvider).toLowerCase() == 'delivery') {
        ref.read(opsVMProvider.notifier).unsubscribe();
        context.go(AlfredConstants.routeDeliveryMainScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tables = ref
        .watch(tableVMProvider)
        .map((id) =>
            TableState(tableNumber: id, isMarked: true, isEnabled: false))
        .toList();
    final newTable = ref
        .watch(tableVMProvider.notifier)
        .getTableStates()
        .firstWhere((t) => t.isNewlyAdded,
            orElse: () => TableState(tableNumber: -1));
    if (newTable.tableNumber != -1 &&
        !tables.any((t) => t.tableNumber == newTable.tableNumber)) {
      tables.add(newTable);
      tables.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
    }
    final buttonTextStyle = GoogleFonts.nunito(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );

    ref.listen(addTableVMProvider, (previous, next) {
      final selectedTable =
          ref.read(tableVMProvider.notifier).selectedTableNumber;
      if (next.toUpperCase() == ROSConstants.success &&
          selectedTable != null &&
          !_isDialogShowing) {
        ref.context.loaderOverlay.hide();
        ref.read(addTableVMProvider.notifier).unsubscribe();
        setState(() {
          _isDialogShowing = true;
        });
        DialogWidget.showMarkingDialog(
          context: context,
          tableNumber: selectedTable,
          onDialogClosed: () {
            setState(() {
              _isDialogShowing = false;
              showBasePointMessage = true;
            });
            ref.read(tableVMProvider.notifier).confirmTable(selectedTable);
            //todo why are we requesting table again
            ref.read(tableVMProvider.notifier).requestTableList();
          },
        );
      }
    });

    ref.listen(
      basePointVMProvider,
      (previous, next) {
        if (next.isNotEmpty) {
          if (next.toUpperCase() == ROSConstants.success) {
            ref.read(basePointVMProvider.notifier).removeReturnToBaseListener();
            ref.read(basePointVMProvider.notifier).removeReturnToBaseAckListener();
            ref.read(tableVMProvider.notifier).resetMarking();
            ref.read(opsVMProvider.notifier).getCurrentOp();
          } else {
            ref.context.loaderOverlay.hide();
          }
        }
      },
    );

    ref.listen(opsVMProvider, (previous, next) {
      if (next.toLowerCase() == 'delivery' &&
          ref.read(tableVMProvider.notifier).hasMarkedTables) {
        ref.read(opsVMProvider.notifier).unsubscribe();
        ref.context.loaderOverlay.hide();
        context.go(AlfredConstants.routeDeliveryMainScreen);
      }
    });

    return Scaffold(
      appBar: AppBarWidget(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.1),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(15.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(horizontal: 63.w),
                              alignment: Alignment.center,
                              child: Text(
                                'Move Alfred manually, place it towards the table and click on Table Number',
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mark Tables",
                                style: GoogleFonts.nunito(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Expanded(
                                child: Scrollbar(
                                  controller: scrollController,
                                  thumbVisibility: true,
                                  child: GridView.builder(
                                    controller: scrollController,
                                    padding: EdgeInsets.all(10.w),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 6,
                                      crossAxisSpacing: 20.w,
                                      mainAxisSpacing: 20.h,
                                      childAspectRatio: 138 / 60,
                                    ),
                                    itemCount:
                                        tables.isEmpty ? 1 : tables.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index < tables.length) {
                                        final table = tables[index];
                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            TableGridButtonWidget(
                                              label:
                                                  table.tableNumber.toString(),
                                              tableNumber: table.tableNumber,
                                              isSelected: table.isSelected,
                                              isMarked: table.isMarked,
                                              isDisabled: table.isMarked,
                                              onPressed: () {
                                                if (!table.isMarked) {
                                                  ref
                                                      .read(tableVMProvider
                                                          .notifier)
                                                      .selectTable(
                                                          table.tableNumber);
                                                }
                                              },
                                            ),
                                            if (table.isMarked)
                                              Positioned(
                                                top: -10.h,
                                                right: 30.w,
                                                child: RemoveTableButtonWidget(
                                                  onPressed: () {
                                                    ref
                                                        .read(tableVMProvider
                                                            .notifier)
                                                        .removeTable(
                                                            table.tableNumber);
                                                  },
                                                ),
                                              ),
                                          ],
                                        );
                                      } else {
                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            TableGridButtonWidget(
                                              label: "Add Table",
                                              isDashed: true,
                                              isDisabled: showBasePointMessage,
                                              onPressed: () {
                                                AddTableDialogWidget
                                                    .showAddTableDialog(
                                                  context: context,
                                                  tableNumberController:
                                                      _tableNumberController,
                                                  ref: ref,
                                                  tablesFromROS:
                                                      ref.read(tableVMProvider),
                                                  onTableAdded: (newTableNum) {
                                                    ref
                                                        .read(tableVMProvider
                                                            .notifier)
                                                        .addTable(newTableNum);
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 20.h),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: showBasePointMessage
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ButtonWidget(
                                              text: "Mark Next Table",
                                              onPressed: () {
                                                setState(() {
                                                  showBasePointMessage = false;
                                                });
                                                ref
                                                    .read(addTableVMProvider
                                                        .notifier)
                                                    .addTableAck();
                                                ref
                                                    .read(tableVMProvider
                                                        .notifier)
                                                    .resetMarking();
                                              },
                                              isActive: true,
                                              width: 300.w,
                                              height: 70.h,
                                            ),
                                            SizedBox(width: 100.w),
                                            ButtonWidget(
                                              text: "Return to Base",
                                              onPressed: () {
                                                ref.context.loaderOverlay.show();
                                                ref.read(basePointVMProvider.notifier).getReturnToBaseAck();
                                                ref.read(tableVMProvider.notifier).resetMarking();
                                                ref.read(basePointVMProvider.notifier).triggerReturnToBase();
                                              },
                                              isActive: true,
                                              width: 300.w,
                                              height: 70.h,
                                              backgroundColor: Colors.white,
                                              borderSide: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.5.w),
                                              textStyle: buttonTextStyle,
                                            ),
                                          ],
                                        )
                                      : ConstrainedBox(
                                          constraints:
                                              BoxConstraints(maxWidth: 600.w),
                                          child: ButtonWidget(
                                            text: "Confirm",
                                            isActive: ref
                                                    .read(tableVMProvider
                                                        .notifier)
                                                    .selectedTableNumber !=
                                                null,
                                            onPressed: ref
                                                        .read(tableVMProvider
                                                            .notifier)
                                                        .selectedTableNumber !=
                                                    null
                                                ? () {
                                                    final selectedTable = ref
                                                        .read(tableVMProvider
                                                            .notifier)
                                                        .selectedTableNumber!;
                                                    ref.context.loaderOverlay
                                                        .show();
                                                    ref
                                                        .read(addTableVMProvider
                                                            .notifier)
                                                        .addTable(
                                                            table:
                                                                selectedTable);
                                                  }
                                                : null,
                                            width: 600.w,
                                          ),
                                        ),
                                ),
                              ),
                            ],
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
    );
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
