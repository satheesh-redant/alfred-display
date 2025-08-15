import 'package:alfred/models/table_state.dart';
import 'package:alfred/view_models/add_table_view_model.dart';
import 'package:alfred/view_models/base_point_view_model.dart';
import 'package:alfred/view_models/table_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../src/core/configs/ros_constants.dart';
import '../widgets/add_table_dialog_widget.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/dialog_widget.dart';
import '../widgets/outline_button_widget.dart';
import '../widgets/remove_table_button_widget.dart';
import '../widgets/table_grid_button_widget.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  static const _gridPadding = 10.0;
  static const _sectionPadding = 15.0;
  final _scrollController = ScrollController();
  final _tableNumberController = TextEditingController();

  bool _isDialogShowing = false;
  bool _showBasePointMessage = false;

  // @override
  // void initState() {
  //   super.initState();
  //   ref.read(tableVMProvider.notifier).requestTableList();
  //   ref.read(tableVMProvider.notifier).getTableList();
  // }

  void _showMarkingDialog(int tableNumber) {
    setState(() => _isDialogShowing = true);

    DialogWidget.showMarkingDialog(
      context: context,
      tableNumber: tableNumber,
      onDialogClosed: () {
        setState(() {
          _isDialogShowing = false;
          _showBasePointMessage = true;
        });
        ref.read(tableVMProvider.notifier).confirmTable(tableNumber);
        ref.read(tableVMProvider.notifier).requestTableList();
      },
    );
  }

  List<TableState> _computeTables() {
    final tableIds = ref.watch(tableVMProvider);

    // If no tables are marked, show the default 10 tables (1 to 10)
    final baseList = (tableIds.isEmpty)
        ? List.generate(
            10,
            (index) => TableState(
              tableNumber: index + 1,
              isMarked: false,
              isEnabled: true, // assuming default enabled for initial tables
            ),
          )
        : tableIds
            .map((id) =>
                TableState(tableNumber: id, isMarked: true, isEnabled: false))
            .toList();

    final newTable = ref
        .read(tableVMProvider.notifier)
        .getTableStates()
        .firstWhere((t) => t.isNewlyAdded,
            orElse: () => TableState(tableNumber: -1));

    if (newTable.tableNumber != -1 &&
        !baseList.any((t) => t.tableNumber == newTable.tableNumber)) {
      baseList.add(newTable);
      baseList.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
    }

    return baseList;
  }

  @override
  Widget build(BuildContext context) {
    // listen for table-add success
    ref.listen<String>(addTableVMProvider, (prev, next) {
      final selected = ref.read(tableVMProvider.notifier).selectedTableNumber;
      if (next.toUpperCase() == ROSConstants.success &&
          selected != null &&
          !_isDialogShowing) {
        ref.context.loaderOverlay.hide();
        // ref.read(addTableVMProvider.notifier).unsubscribe();
        _showMarkingDialog(selected);
      }
    });

    // listen for base-point ack
    // ref.listen<String>(basePointVMProvider, (prev, next) {
    //   if (next.isEmpty) return;
    //   if (next.toUpperCase() == ROSConstants.success) {
    //     ref.read(basePointVMProvider.notifier).removeReturnToBaseListener();
    //     ref.read(basePointVMProvider.notifier).removeReturnToBaseAckListener();
    //     ref.read(tableVMProvider.notifier).resetMarking();
    //     ref.read(opsVMProvider.notifier).getCurrentOp();
    //   } else {
    //     ref.context.loaderOverlay.hide();
    //     }
    // });

    // navigate to delivery if ops change
    // ref.listen<String>(opsVMProvider, (prev, next) {
    //   if (next.toLowerCase() == 'delivery' &&
    //       ref.read(tableVMProvider.notifier).hasMarkedTables) {
    //     ref.read(opsVMProvider.notifier).unsubscribe();
    //     ref.context.loaderOverlay.hide();
    //     context.go(AlfredConstants.routeDeliveryMainScreen);
    //   }
    // });

    final tables = _computeTables();

    return Scaffold(
      appBar: AppBarWidget(),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                  left: _sectionPadding.w,
                  // right: _sectionPadding.w,
                  bottom: _sectionPadding.h,
                  top: 60.h),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: EdgeInsets.only(
                              left: 40.w, right: 40.w, top: 30.h),
                          child: Column(
                            children: [
                              _buildInstruction1(),
                              Image.asset(
                                "assets/images/alfred_base_point.png",
                                width: 450.w,
                                height: 550.h,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ))),
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.r),
                              bottomLeft: Radius.circular(12.r)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10),
                                child: _buildInstruction2(),),
                            const SizedBox(height: 20),
                            Expanded(child: _buildTableGrid(tables)),
                            const SizedBox(height: 20),
                            _buildActionButtons(),
                          ],
                        ),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/background_image.png',
        fit: BoxFit.cover,
        color: Colors.white.withOpacity(0.1),
        colorBlendMode: BlendMode.darken,
      ),
    );
  }

  Widget _buildInstruction1() {
    return Text(
      'Move Alfred manually, place it towards the table and click on Table Number',
      style: GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      maxLines: 4,
    );
  }

  Widget _buildInstruction2() {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Mark Table (Only single selection is allowed)',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          maxLines: 4,
        ));
  }

  Widget _buildTableGrid(List<TableState> tables) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(_gridPadding.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 20.w,
          mainAxisSpacing: 40.h,
          childAspectRatio: 138 / 60,
        ),
        itemCount: tables.length + 1,
        // +1 for "Add Table" tile
        itemBuilder: (_, idx) {
          if (idx < tables.length) {
            final t = tables[idx];
            final stackBtn = Stack(
              clipBehavior: Clip.none,
              children: [
                TableGridButtonWidget(
                  label: t.tableNumber.toString(),
                  tableNumber: t.tableNumber,
                  isSelected: t.isSelected,
                  isMarked: t.isMarked,
                  isDisabled: t.isMarked,
                  onPressed: () {
                    if (!t.isMarked) {
                      ref
                          .read(tableVMProvider.notifier)
                          .selectTable(t.tableNumber);
                    }
                  },
                ),
                if (t.isMarked)
                  Align(
                    alignment: Alignment.topRight,
                    child: FractionalTranslation(
                        translation: const Offset(0.25, -0.25),
                        child: RemoveTableButtonWidget(
                          onPressed: () => ref
                              .read(tableVMProvider.notifier)
                              .removeTable(t.tableNumber),
                        )),
                  ),
              ],
            );
            return Center(
              child: SizedBox(
                width: 138.w,
                height: 60.h,
                child: stackBtn,
              ),
            );
          } else {
            final dottedBtn = TableGridButtonWidget(
              label: 'Add Table',
              isDashed: true,
              isDisabled: _showBasePointMessage,
              onPressed: () {
                AddTableDialogWidget.showAddTableDialog(
                  context: context,
                  tableNumberController: _tableNumberController,
                  ref: ref,
                  tablesFromROS: ref.read(tableVMProvider),
                  onTableAdded: (n) =>
                      ref.read(tableVMProvider.notifier).addTable(n),
                );
              },
            );
            return Center(
              child: SizedBox(width: 138.w, height: 60.h, child: dottedBtn),
            );
          }
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    final selected = ref.read(tableVMProvider.notifier).selectedTableNumber;
    if (_showBasePointMessage) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ButtonWidget(
              text: 'Mark Next Table',
              width: 300.w,
              height: 70.h,
              isActive: true,
              onPressed: () {
                setState(() => _showBasePointMessage = false);
                ref.read(tableVMProvider.notifier).resetMarking();
              },
            ),
            flex: 1,
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: OutlineButtonWidget(
              text: 'Return to Base',
              width: 300.w,
              height: 70.h,
              isActive: true,
              onPressed: () {
                ref.context.loaderOverlay.show();
                ref.read(tableVMProvider.notifier).resetMarking();
                ref.read(basePointVMProvider.notifier).triggerReturnToBase();
              },
            ),
            flex: 1,
          ),
        ],
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600.w),
      child: ButtonWidget(
        text: 'Confirm',
        width: 600.w,
        isActive: selected != null,
        onPressed: selected != null
            ? () {
                ref.context.loaderOverlay.show();
                ref.read(addTableVMProvider.notifier).addTable(table: selected);
              }
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
