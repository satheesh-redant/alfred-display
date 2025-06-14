
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
import '../../models/table_data.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/remove_table_button_widget.dart';
import '../widgets/table_grid_button_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/dialog_widget.dart';
import '../widgets/add_table_dialog_widget.dart';

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
  final TextEditingController _tableNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(opsVMProvider.notifier).getCurrentOp();
    ref.read(tableVMProvider.notifier).getTableList();
    ref.read(addTableVMProvider.notifier).addTableAck();
  }

  @override
  Widget build(BuildContext context) {
    final tables = ref.watch(tableVMProvider);
    ref.watch(addTableVMProvider);

    final selectedTable = tables.firstWhere(
          (table) => table.isSelected,
      orElse: () => TableData(table: -1, isMarked: false, isSelected: false),
    );

    ref.listen(addTableVMProvider, (previous, next) {
      print('addTableVMProvider state changed: $next (Previous: $previous)');
      if (next == 'Success' &&
          selectedTable.table != -1 &&
          !_isDialogShowing &&
          _lastMarkedTable != selectedTable.table) {
        print('Showing dialog for table ${selectedTable.table}');
        ref.context.loaderOverlay.hide();
        setState(() {
          _isDialogShowing = true;
          _lastMarkedTable = selectedTable.table;
        });
        DialogWidget.showMarkingDialog(
          context: context,
          tableNumber: selectedTable.table,
          onDialogClosed: () {
            setState(() {
              _isDialogShowing = false;
              _isTableMarked = true;
              showBasePointMessage = true;
            });
          },
        );
      } else {
        print('Dialog not shown: _isDialogShowing=$_isDialogShowing, _lastMarkedTable=$_lastMarkedTable, currentTable=${selectedTable.table}');
      }
    });

    ref.listen(basePointVMProvider, (previous, next) {
      print('basePointVMProvider state changed: $next');
      if (next == "Success") {
        ref.read(basePointVMProvider.notifier).removeReturnToBaseListener();
      }
    });

    ref.listen(opsVMProvider, (previous, next) {
      print('opsVMProvider state changed: $next');
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
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_image.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.1),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Main Content
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 15.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Text Section
                      Container(
                        padding: EdgeInsets.only(top: 10.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(top: 20.h, left: 63.w, right: 63.w),
                              alignment: Alignment.center,
                              child: Text(
                                showBasePointMessage
                                    ? 'You are at your Base Point, please move Alfred towards table to start marking'
                                    : 'Move Alfred manually, place it towards the table and click on Table Number',
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w400,
                                  height: 24.2 / 18, // Line height multiplier, not scaled
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                      // Table Grid Section (Full Screen Width)
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.w),
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1.w,
                                blurRadius: 4.w,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mark Tables",
                                style: GoogleFonts.nunito(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.20, // Line height multiplier, not scaled
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Scrollbar(
                                    controller: scrollController,
                                    thumbVisibility: true,
                                    trackVisibility: true,
                                    child: GridView.builder(
                                      controller: scrollController,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(10.w),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 6,
                                        crossAxisSpacing: 20.w,
                                        mainAxisSpacing: 20.h,
                                        childAspectRatio: 138 / 60, // Matches 138.w x 60.h
                                      ),
                                      itemCount: tables.length + 1,
                                      itemBuilder: (context, index) {
                                        if (index < tables.length) {
                                          final table = tables[index];
                                          return Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              TableGridButtonWidget(
                                                label: table.table.toString(),
                                                tableNumber: table.table,
                                                isSelected: table.isSelected,
                                                isDisabled: table.isMarked,
                                                isMarked: table.isMarked,
                                                onPressed: table.isMarked
                                                    ? () {
                                                  showErrorToast(
                                                    context: context,
                                                    description:
                                                    'Table ${table.table} is already marked',
                                                  );
                                                }
                                                    : () {
                                                  ref
                                                      .read(tableVMProvider.notifier)
                                                      .selectTable(table.table);
                                                },
                                              ),
                                              if (table.isMarked)
                                                Positioned(
                                                  top: -10.h,
                                                  right: 30.w,
                                                  child: RemoveTableButtonWidget(
                                                    onPressed: () {
                                                      ref
                                                          .read(tableVMProvider.notifier)
                                                          .removeTable(table: table.table);
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
                                                isDisabled: false,
                                                onPressed: () {
                                                  AddTableDialogWidget.showAddTableDialog(
                                                    context: context,
                                                    tableNumberController: _tableNumberController,
                                                    ref: ref,
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
                                        onPressed: () {
                                          setState(() {
                                            _isTableMarked = false;
                                            showBasePointMessage = false;
                                            _lastMarkedTable = null;
                                          });
                                          ref
                                              .read(tableVMProvider.notifier)
                                              .selectTable(null);
                                          ref
                                              .read(addTableVMProvider.notifier)
                                              .addTableAck();
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
                                          ref
                                              .read(basePointVMProvider.notifier)
                                              .getReturnToBaseAck();
                                          ref
                                              .read(tableVMProvider.notifier)
                                              .returnToBase();
                                        },
                                        isActive: true,
                                        width: 300.w,
                                        height: 70.h,
                                        backgroundColor: Colors.white,
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1.5.w,
                                        ),
                                        textStyle: buttonTextStyle,
                                      ),
                                    ],
                                  )
                                      : ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 600.w),
                                    child: ButtonWidget(
                                      text: "Confirm",
                                      onPressed: selectedTable.table != -1
                                          ? () {
                                        if (selectedTable.isMarked) {
                                          showErrorToast(
                                            context: context,
                                            description:
                                            'Table ${selectedTable.table} is already marked',
                                          );
                                          return;
                                        }
                                        ref.context.loaderOverlay.show();
                                        ref
                                            .read(addTableVMProvider.notifier)
                                            .addTableAck();
                                        ref
                                            .read(addTableVMProvider.notifier)
                                            .addTable(
                                          table: selectedTable.table,
                                        );
                                      }
                                          : null,
                                      isActive: selectedTable.table != -1,
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