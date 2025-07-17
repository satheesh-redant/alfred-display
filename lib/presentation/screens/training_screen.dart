import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/config/ros_constants.dart';
import 'package:alfred/models/table_state.dart';
import 'package:alfred/view_models/add_table_view_model.dart';
import 'package:alfred/view_models/base_point_view_model.dart';
import 'package:alfred/view_models/operation_view_model.dart';
import 'package:alfred/view_models/table_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:go_router/go_router.dart';

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
  static const _gridPadding = 10.0;
  static const _sectionPadding = 15.0;
  final _scrollController = ScrollController();
  final _tableNumberController = TextEditingController();

  bool _isDialogShowing = false;
  bool _showBasePointMessage = false;

  bool _listenersRegistered = false;

  TextStyle get _buttonTextStyle => GoogleFonts.nunito(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      );

  @override
  void initState() {
    super.initState();
    // kick off initial ROS requests
    ref.read(addTableVMProvider.notifier).addTableAck();
    ref.read(tableVMProvider.notifier).requestTableList();
  }

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
    final baseList = tableIds
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
    if (!_listenersRegistered) {
      _listenersRegistered = true;

      // listen for table-add success
      ref.listen<String>(addTableVMProvider, (prev, next) {
        final selected = ref.read(tableVMProvider.notifier).selectedTableNumber;
        if (next.toUpperCase() == ROSConstants.success &&
            selected != null &&
            !_isDialogShowing) {
          ref.context.loaderOverlay.hide();
          ref.read(addTableVMProvider.notifier).unsubscribe();
          _showMarkingDialog(selected);
        }
      });

      // listen for base-point ack
      ref.listen<String>(basePointVMProvider, (prev, next) {
        if (next.isEmpty) return;
        if (next.toUpperCase() == ROSConstants.success) {
          ref.read(basePointVMProvider.notifier).removeReturnToBaseListener();
          ref
              .read(basePointVMProvider.notifier)
              .removeReturnToBaseAckListener();
          ref.read(tableVMProvider.notifier).resetMarking();
          ref.read(opsVMProvider.notifier).getCurrentOp();
        } else {
          ref.context.loaderOverlay.hide();
        }
      });

      // navigate to delivery if ops change
      ref.listen<String>(opsVMProvider, (prev, next) {
        if (next.toLowerCase() == 'delivery' &&
            ref.read(tableVMProvider.notifier).hasMarkedTables) {
          ref.read(opsVMProvider.notifier).unsubscribe();
          ref.context.loaderOverlay.hide();
          context.go(AlfredConstants.routeDeliveryMainScreen);
        }
      });
    }

    final tables = _computeTables();

    return Scaffold(
      appBar: AppBarWidget(),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(_sectionPadding.w),
              child: Column(
                children: [
                  _buildInstruction(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildMarkTablesContainer(tables)),
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
        color: Colors.black.withOpacity(0.1),
        colorBlendMode: BlendMode.darken,
      ),
    );
  }

  Widget _buildInstruction() {
    return Center(
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
    );
  }

  Widget _buildMarkTablesContainer(List<TableState> tables) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mark Tables',
              style: GoogleFonts.nunito(
                  fontSize: 16.sp, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Expanded(child: _buildTableGrid(tables)),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTableGrid(List<TableState> tables) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(_gridPadding.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 20.w,
          mainAxisSpacing: 20.h,
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
                      ref.read(tableVMProvider.notifier).selectTable(t.tableNumber);
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
          ButtonWidget(
            text: 'Mark Next Table',
            width: 300.w,
            height: 70.h,
            isActive: true,
            onPressed: () {
              setState(() => _showBasePointMessage = false);
              ref.read(addTableVMProvider.notifier).addTableAck();
              ref.read(tableVMProvider.notifier).resetMarking();
            },
          ),
          SizedBox(width: 100.w),
          ButtonWidget(
            text: 'Return to Base',
            width: 300.w,
            height: 70.h,
            isActive: true,
            backgroundColor: Colors.white,
            borderSide: BorderSide(color: Colors.black, width: 1.5.w),
            textStyle: _buttonTextStyle,
            onPressed: () {
              ref.context.loaderOverlay.show();
              ref.read(basePointVMProvider.notifier).getReturnToBaseAck();
              ref.read(tableVMProvider.notifier).resetMarking();
              ref.read(basePointVMProvider.notifier).triggerReturnToBase();
            },
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
