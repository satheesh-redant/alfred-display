
import 'dart:async';
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
import '../../core/toast_utils.dart';
import '../../providers/removed_tables_provider.dart';
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
  bool showBasePointMessage = false;
  bool _isDialogShowing = false;
  bool _isTableMarked = false;
  int? _lastMarkedTable;
  int? _selectedTableNumber;

  final List<int> _pendingTableIds = [];
  final TextEditingController _tableNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(opsVMProvider.notifier).getCurrentOp();
    ref.read(addTableVMProvider.notifier).addTableAck();
    ref.read(tableVMProvider.notifier).getTableList();
    ref.read(tableVMProvider.notifier).requestTableList();
  }

  @override
  Widget build(BuildContext context) {
    final rosMarkedTableIds = ref.watch(tableVMProvider);
    final sessionRemovedTableIds = ref.watch(removedTablesProvider);

    final markedTableIds = rosMarkedTableIds
        .where((id) => !sessionRemovedTableIds.contains(id))
        .toList();

    final allDisplayTableIds = {
      ...markedTableIds,
      ..._pendingTableIds,
    }.toList()
      ..sort();

    ref.watch(addTableVMProvider);

    ref.listen(addTableVMProvider, (previous, next) {
      if (next == 'Success' && _selectedTableNumber != null) {
        if (_isDialogShowing) return;

        ref.context.loaderOverlay.hide();
        setState(() {
          _isDialogShowing = true;
          _lastMarkedTable = _selectedTableNumber;
        });

        DialogWidget.showMarkingDialog(
          context: context,
          tableNumber: _selectedTableNumber!,
          onDialogClosed: () {
            setState(() {
              _isDialogShowing = false;
              _isTableMarked = true;
              showBasePointMessage = true;
              _pendingTableIds.remove(_selectedTableNumber);
              _selectedTableNumber = null;
            });

            ref.read(tableVMProvider.notifier).requestTableList();
          },
        );
      }
    });

    ref.listen(basePointVMProvider, (previous, next) {
      if (next == "Success") {
        ref.read(basePointVMProvider.notifier).removeReturnToBaseListener();
      }
    });

    ref.listen(opsVMProvider, (previous, next) {
      if (next.toLowerCase() == 'delivery') {
        ref.context.loaderOverlay.hide();
        ref.read(opsVMProvider.notifier).unsubscribe();
        context.go(AlfredConstants.routeDeliveryMainScreen);
      }
    });

    final buttonTextStyle = GoogleFonts.nunito(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );

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
                                _isTableMarked
                                    ? 'You are at your Base Point, please move Alfred towards table to start marking'
                                    : 'Move Alfred manually, place it towards the table and click on Table Number',
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
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 6,
                                      crossAxisSpacing: 20.w,
                                      mainAxisSpacing: 20.h,
                                      childAspectRatio: 138 / 60,
                                    ),
                                    itemCount: allDisplayTableIds.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index < allDisplayTableIds.length) {
                                        final tableId = allDisplayTableIds[index];
                                        final bool isMarked = markedTableIds.contains(tableId);
                                        final bool isSelected = tableId == _selectedTableNumber;

                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            TableGridButtonWidget(
                                              label: tableId.toString(),
                                              tableNumber: tableId,
                                              isSelected: isSelected,
                                              isMarked: isMarked,
                                              isDisabled: isMarked,
                                              onPressed: () {
                                                if (isMarked) return;
                                                setState(() {
                                                  _selectedTableNumber = isSelected ? null : tableId;
                                                });
                                              },
                                            ),
                                            if (isMarked)
                                              Positioned(
                                                top: -10.h,
                                                right: 30.w,
                                                child: RemoveTableButtonWidget(
                                                  onPressed: () {
                                                    ref.read(removedTablesProvider.notifier).add(tableId);
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
                                              isDisabled: _isTableMarked,
                                              onPressed: () {
                                                AddTableDialogWidget.showAddTableDialog(
                                                  context: context,
                                                  tableNumberController: _tableNumberController,
                                                  ref: ref,
                                                  tablesFromROS: rosMarkedTableIds,
                                                  onTableAdded: (newTableNum) {
                                                    setState(() {
                                                      ref.read(removedTablesProvider.notifier).remove(newTableNum);
                                                      if (!allDisplayTableIds.contains(newTableNum)) {
                                                        _pendingTableIds.add(newTableNum);
                                                      }
                                                    });
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
                                  child: _isTableMarked
                                      ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ButtonWidget(
                                        text: "Mark Next Table",
                                        onPressed: () => setState(() => _isTableMarked = false),
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
                                        },
                                        isActive: true,
                                        width: 300.w,
                                        height: 70.h,
                                        backgroundColor: Colors.white,
                                        borderSide: BorderSide(color: Colors.black, width: 1.5.w),
                                        textStyle: buttonTextStyle,
                                      ),
                                    ],
                                  )
                                      : ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 600.w),
                                    child: ButtonWidget(
                                      text: "Confirm",
                                      isActive: _selectedTableNumber != null,
                                      onPressed: _selectedTableNumber != null
                                          ? () {
                                        ref.context.loaderOverlay.show();
                                        ref
                                            .read(addTableVMProvider.notifier)
                                            .addTable(table: _selectedTableNumber!);
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
}