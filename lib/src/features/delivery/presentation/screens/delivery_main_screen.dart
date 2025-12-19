import 'package:alfred/src/core/configs/alfred_constants.dart';
import 'package:alfred/src/features/delivery/presentation/view_models/delivery_view_model.dart';
import 'package:alfred/src/shared/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:slider_button/slider_button.dart';

import '../../data/models/delivery_models.dart';
import '../providers/delivery_providers.dart';
import '../widgets/table_grid_widget.dart';
import '../widgets/delivery_action_button.dart';

class DeliveryScreen extends ConsumerStatefulWidget {
  const DeliveryScreen({super.key});

  @override
  ConsumerState<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen> {
  final ScrollController _gridScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deliveryViewModelProvider.notifier).loadTables();
    });
  }

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryViewModelProvider);
    final viewModel = ref.read(deliveryViewModelProvider.notifier);

    ref.listen(deliveryViewModelProvider, (previous, next) {
      if (next.state == DeliveryState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }

      // if (previous?.state == DeliveryState.moving &&
      //     next.state == DeliveryState.delivered &&
      //     next.isTableToBase) {
      //   Future.delayed(const Duration(seconds: 2), () {
      //     viewModel.resetToIdle();
      //   });
      // }

      // POWER-OFF ACK HANDLING ADDED (only change)
      if (next.powerOffAck) {
        context.loaderOverlay.hide();
        context.go(AlfredConstants.routeSoftShutdownScreen);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AlfredAppBarWidget(),
      body: _buildBody(deliveryState, viewModel),
    );
  }

  Widget _buildBody(DeliveryData deliveryState, DeliveryViewModel viewModel) {
    if (deliveryState.state == DeliveryState.idle) {
      return _buildTableSelectionView(deliveryState, viewModel);
    } else if (deliveryState.state == DeliveryState.moving) {
      return _buildDeliveryProgressView(deliveryState, viewModel);
    } else {
      /*if (deliveryState.isTableToBase) {
        return _buildTableSelectionView(deliveryState, viewModel);
      } else {
        return _buildDeliveryCompletedView(deliveryState, viewModel);
      }*/
      return _buildDeliveryCompletedView(deliveryState, viewModel);
    }
  }

  Widget _buildTableSelectionView(
      DeliveryData deliveryState, DeliveryViewModel viewModel) {
    final availableTables = viewModel.availableTables;

    return Container(
        padding: EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSidebar(),
            _buildAlfredBaseSection(deliveryState),
            SizedBox(width: 20.w),
            _buildTableSelectionSection(
                availableTables, deliveryState, viewModel),
          ],
        ));
  }

  Widget _buildSidebar() {
    return Padding(
      padding: EdgeInsets.only(left: 0.w, top: 70.h),
      child: SizedBox(
        width: 63.w,
        height: 350.h,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/Edit_icon.svg',
                  width: 31.w,
                  height: 31.h,
                ),
                onPressed: () {
                  context.loaderOverlay.show();
                },
              ),
              Center(
                child: Text(
                  'Training \nMode',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    color: Colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.20,
                    letterSpacing: 0.24.w,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/setting_icon.svg',
                  width: 36.w,
                  height: 36.h,
                ),
                onPressed: () {},
              ),
              Text(
                "Settings",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: Colors.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.20,
                  letterSpacing: 0.24.w,
                ),
              ),
              SizedBox(height: 45.h),

              // POWER OFF BUTTON
              IconButton(
                icon: Icon(Icons.power_settings_new_rounded,
                    color: Colors.red, size: 30),
                onPressed: _showPowerOffDialog,
              ),
              Text(
                "Power Off",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: Colors.red,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UPDATED POWER-OFF DIALOG (ACK logic preserved)
  void _showPowerOffDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          actionsPadding: const EdgeInsets.only(bottom: 24),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.power_settings_new_rounded,
                size: 70,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                "Are you sure you want to\npower off Alfred?",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
          actions: [
            Center(
              child: SliderButton(
                action: () async {
                  Navigator.pop(context);
                  context.loaderOverlay.show();
                  ref.read(deliveryViewModelProvider.notifier).sendPowerOff();
                  return true;
                },
                label: Text(
                  "Slide to Power Off",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: Icon(Icons.power_settings_new, color: Colors.white),
                width: 250,
                height: 60,
                buttonSize: 60,
                buttonColor: Colors.red,
                backgroundColor: Colors.grey.shade200,
                baseColor: Colors.black,
                highlightedColor: Colors.red.shade700,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlfredBaseSection(DeliveryData deliveryState) {
    return Expanded(
      flex: 2,
      child: Stack(
        children: [
          Positioned(
            left: 125.w,
            top: 50.h,
            child: Text(
              "Alfred at Base",
              style: GoogleFonts.nunito(
                fontSize: 20.sp,
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            left: 60.w,
            right: 140.w,
            top: 140.h,
            bottom: 0.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight - 223.h,
                  ),
                  child: Image.asset(
                    "assets/images/alfred_base_point.png",
                    width: 1200.w,
                    height: 1200.h,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSelectionSection(List<int> availableTables,
      DeliveryData deliveryState, DeliveryViewModel viewModel) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: EdgeInsets.only(top: 50.h, right: 40.w),
        child: Card(
          elevation: 6,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Tables",
                  style: GoogleFonts.nunito(
                    fontSize: 16.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 30.h),

                // TABLE GRID INSIDE CARD
                Expanded(
                  child: availableTables.isEmpty
                      ? _buildEmptyTablesMessage()
                      : _buildTableGrid(
                          availableTables,
                          deliveryState,
                          viewModel,
                        ),
                ),

                SizedBox(height: 20.h),

                // BUTTON BELOW GRID INSIDE CARD
                DeliveryActionButton(
                  text: "Go to Table",
                  isEnabled: deliveryState.selectedTable != null,
                  isLoading: deliveryState.state == DeliveryState.moving,
                  onPressed: () => viewModel.goToTable(),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTablesMessage() {
    return Center(
      child: Text(
        "No tables marked yet\nPlease mark tables in Training Mode first",
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(
          fontSize: 16.sp,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildTableGrid(List<int> availableTables, DeliveryData deliveryState,
      DeliveryViewModel viewModel) {
    return Scrollbar(
      controller: _gridScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: GridView.builder(
        controller: _gridScrollController,
        shrinkWrap: false,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 49.w,
          mainAxisSpacing: 26.h,
          childAspectRatio: (138.w / 60.h),
        ),
        itemCount: availableTables.length,
        itemBuilder: (context, index) {
          final tableId = availableTables[index];
          final isSelected = tableId == deliveryState.selectedTable;

          return TableGridButtonWidget(
            label: tableId.toString(),
            tableNumber: tableId,
            isSelected: isSelected,
            isMarked: true,
            onPressed: () {
              viewModel.selectTable(isSelected ? null : tableId);
            },
          );
        },
      ),
    );
  }

  Widget _buildDeliveryProgressView(
      DeliveryData deliveryState, DeliveryViewModel viewModel) {
    return Align(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text(
          //   "Table ${deliveryState.selectedTable ?? ''}",
          //   textAlign: TextAlign.center,
          //   style: GoogleFonts.nunito(
          //     fontSize: 32.sp,
          //     fontWeight: FontWeight.w700,
          //     height: 1.2,
          //     letterSpacing: 0.02.w,
          //     color: Colors.black,
          //   ),
          // ),
          // SizedBox(height: 16.h),
          Text(
            _getProgressMessage(deliveryState),
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: 0.02.w,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 64.h),
          Flexible(
            child: Image.asset(
              _getProgressImage(deliveryState),
              fit: BoxFit.contain,
            ),
          ),
          // if (deliveryState.state == DeliveryState.delivered &&
          //     deliveryState.isBaseToTable)
          //   Padding(
          //     padding: EdgeInsets.only(top: 32.h),
          //     child: DeliveryActionButton(
          //       text: "Return to Base",
          //       isEnabled: true,
          //       onPressed: () => viewModel.returnToBase(),
          //       width: MediaQuery.of(context).size.width * 0.53,
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCompletedView(
      DeliveryData deliveryState, DeliveryViewModel viewModel) {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Destination Reached",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: 0.02.w,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 64.h),
                Flexible(
                  child: Image.asset(
                    _getProgressImage(deliveryState),
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            )),
        _buildTableSelectionSectionSuccess(
            viewModel.availableTables, deliveryState, viewModel),
      ],
    );
  }

  Widget _buildTableSelectionSectionSuccess(List<int> availableTables,
      DeliveryData deliveryState, DeliveryViewModel viewModel) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.only(top: 50.h, right: 40.w),
        child: Card(
          elevation: 6,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Next Destination",
                  style: GoogleFonts.nunito(
                    fontSize: 16.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 30.h),

                // TABLE GRID INSIDE CARD
                Expanded(
                  child: _buildTableGridSuccess(
                    availableTables,
                    deliveryState,
                    viewModel,
                  ),
                ),

                SizedBox(height: 20.h),

                // BUTTON BELOW GRID INSIDE CARD
                DeliveryActionButton(
                  text:
                      "Go to ${deliveryState.selectedTable == 0 ? 'Base' : 'Table ${deliveryState.selectedTable}'}",
                  isEnabled: deliveryState.selectedTable != null,
                  isLoading: deliveryState.state == DeliveryState.moving,
                  onPressed: () => viewModel.goToTable(),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableGridSuccess(List<int> availableTables,
      DeliveryData deliveryState, DeliveryViewModel viewModel) {
    return Scrollbar(
      controller: _gridScrollController,
      thumbVisibility: true,
      trackVisibility: true,
      child: GridView.builder(
        controller: _gridScrollController,
        shrinkWrap: false,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 49.w,
          mainAxisSpacing: 26.h,
          childAspectRatio: (138.w / 60.h),
        ),
        itemCount: availableTables.length,
        itemBuilder: (context, index) {
          final tableId = availableTables[index];
          final isSelected = tableId == deliveryState.selectedTable;

          return TableGridButtonWidget(
            label: tableId == 0 ? 'Base' : tableId.toString(),
            tableNumber: tableId,
            isSelected: isSelected,
            isMarked: true,
            onPressed: () {
              viewModel.selectTable(isSelected ? null : tableId);
            },
          );
        },
      ),
    );
  }

  String _getProgressMessage(DeliveryData deliveryState) {
    if (deliveryState.state == DeliveryState.moving) {
      return deliveryState.isBaseToTable
          ? "Alfred is on move..."
          : "Alfred is returning...";
    } else if (deliveryState.state == DeliveryState.delivered) {
      return deliveryState.isBaseToTable
          ? "Ready to serve"
          : "Alfred is back at base";
    }
    return "Alfred is on move...";
  }

  String _getProgressImage(DeliveryData deliveryState) {
    if (deliveryState.state == DeliveryState.moving) {
      return "assets/images/alfred_moving.png";
    } else if (deliveryState.state == DeliveryState.delivered) {
      if (deliveryState.isBaseToTable) {
        return "assets/images/alfred_ready.png";
      } else {
        return "assets/images/alfred_base_point.png";
      }
    }
    return "assets/images/alfred_base_moving_img.png";
  }
}
