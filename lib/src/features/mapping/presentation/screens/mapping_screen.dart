

import 'package:alfred/src/features/mapping/view_model/table_state.dart';
import 'package:alfred/src/core/configs/ros_constants.dart';
import 'package:alfred/src/features/mapping/presentation/screens/confirmation_dialog.dart';
import 'package:alfred/src/shared/widgets/appbar_widget.dart';
import 'package:alfred/src/features/mapping/view_model/add_table_view_model.dart';
import 'package:alfred/src/features/routing/base_point_view_model.dart';
import 'package:alfred/src/features/routing/table_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:alfred/src/features/mapping/presentation/widgets/map_display_widget.dart';
import 'package:alfred/src/core/providers/core_providers.dart';
import 'package:alfred/src/features/mapping/view_model/mapping_view_model.dart';
import 'package:alfred/src/features/loading/providers/loading_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:alfred/src/core/configs/alfred_constants.dart';
import '../widgets/dialog_widget.dart';

class TrainingScreen extends ConsumerStatefulWidget {
  const TrainingScreen({super.key});

  @override
  ConsumerState<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends ConsumerState<TrainingScreen> {
  static const _sectionPadding = 15.0;
  final _scrollController = ScrollController();
  final _tableNumberController = TextEditingController();
  bool _isDialogShowing = false;
  bool _showBasePointMessage = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasInitialized) {
        final vm = ref.read(mappingVMProvider.notifier);
        vm.initialize().then((_) => vm.startMapping());
        _hasInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tables = _computeTables();

    ref.listen<String>(addTableVMProvider, (prev, next) {
      final selected = ref.read(tableVMProvider.notifier).selectedTableNumber;
      if (next.toUpperCase() == ROSConstants.success &&
          selected != null &&
          !_isDialogShowing) {
        ref.context.loaderOverlay.hide();
        _showMarkingDialog(selected);
      }
    });

    ref.listen(mappingVMProvider, (previous, next) {
      if (previous?.isSaving != next.isSaving) {
        next.isSaving ? context.loaderOverlay.show() : context.loaderOverlay.hide();
      }
      if (!(previous?.mapSaved ?? false) && next.mapSaved) {
        showDialog(
          context: context,
          builder: (_) => ConfirmationDialog(
            title: "Map Saved Successfully",
            message:
            "Would you like to go to the route planning screen to create navigation routes?",
            onYes: () {
              context.loaderOverlay.show();
              ref.read(rosServiceProvider).publishToTopic(
                "/ops_mode",
                "std_msgs/String",
                {"data": "routing"},
              );
            },
            onNo: () {},
          ),
        );
      }
    });

    ref.listen(currentOperationModeProvider, (previous, next) {
      if (next.value?.toLowerCase() == 'routing') {
        context.loaderOverlay.hide();
        context.go(AlfredConstants.routeRoutingScreen);
      }
    });

    return Scaffold(
      appBar: AlfredAppBarWidget(),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: _sectionPadding.w,
                bottom: _sectionPadding.h,
                top: 60.h,
              ),
              child: Row(
                children: [
                  // LEFT SIDE FIXED (TEXT EXACTLY ABOVE IMAGE NOW)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(left: 40.w, right: 40.w, top: 30.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,   // 🔥 ONLY CHANGE
                        children: [
                          _buildInstruction1(),
                          SizedBox(height: 30),
                          Image.asset(
                            "assets/images/alfred_base_point.png",
                            width: 450.w,
                            height: 550.h,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // RIGHT SIDE MAP
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          bottomLeft: Radius.circular(12.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: _buildInstruction2(),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: MapDisplayWidget(
                              onSaveMap: () {
                                ref.read(mappingVMProvider.notifier).saveMap();
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
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
    );
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
    final baseList = (tableIds.isEmpty)
        ? List.generate(10, (i) => TableState(tableNumber: i + 1, isMarked: false, isEnabled: true))
        : tableIds
        .map((id) => TableState(tableNumber: id, isMarked: true, isEnabled: false))
        .toList();

    final newTable = ref.read(tableVMProvider.notifier).getTableStates()
        .firstWhere((t) => t.isNewlyAdded, orElse: () => TableState(tableNumber: -1));

    if (newTable.tableNumber != -1 &&
        !baseList.any((t) => t.tableNumber == newTable.tableNumber)) {
      baseList.add(newTable);
      baseList.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
    }
    return baseList;
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

  Widget _buildInstruction1() => Text(
    'Move Alfred manually, place it towards the table and click on Table Number',
    style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w400),
    maxLines: 4,
    textAlign: TextAlign.center,
  );

  Widget _buildInstruction2() => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      'Mark Table (Only single selection is allowed)',
      style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w400),
    ),
  );

  @override
  void dispose() {
    _tableNumberController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
