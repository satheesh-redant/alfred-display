import 'package:alfred/presentation/widgets/appbar_widget.dart';
import 'package:alfred/src/features/delivery/presentation/view_models/delivery_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
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
    // Request table list when screen loads
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

    // Listen for state changes and handle loading overlay
    ref.listen(deliveryViewModelProvider, (previous, next) {
      // Handle loading overlay
      // if (next.state == DeliveryState.moving && previous?.state != DeliveryState.moving) {
      //   context.loaderOverlay.show();
      // } else if (next.state != DeliveryState.moving && previous?.state == DeliveryState.moving) {
      //   context.loaderOverlay.hide();
      // }

      // Handle error states
      if (next.state == DeliveryState.error) {
        // context.loaderOverlay.hide();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }

      // Auto-reset when delivery cycle completes
      if (previous?.state == DeliveryState.moving &&
          next.state == DeliveryState.delivered &&
          next.isTableToBase) {
        Future.delayed(const Duration(seconds: 2), () {
          viewModel.resetToIdle();
        });
      }
    });

    return Scaffold(
      body: _buildBody(deliveryState, viewModel),
    );
  }

  Widget _buildBody(DeliveryData deliveryState, DeliveryViewModel viewModel) {
    if (deliveryState.state == DeliveryState.idle) {
      return _buildTableSelectionView(deliveryState, viewModel);
    } else {
      return _buildDeliveryProgressView(deliveryState, viewModel);
    }
  }

  Widget _buildTableSelectionView(DeliveryData deliveryState, DeliveryViewModel viewModel) {
    final availableTables = viewModel.availableTables;

    return Column(
      children: [
        AppBarWidget(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar
              _buildSidebar(),

              // Middle Section - Alfred at Base
              _buildAlfredBaseSection(deliveryState),

              SizedBox(width: 20.w),

              // Table Selection Section
              _buildTableSelectionSection(availableTables, deliveryState, viewModel),
            ],
          ),
        ),

        // Bottom Action Button
        _buildBottomActionButton(deliveryState, viewModel),
      ],
    );
  }

  Widget _buildSidebar() {
    return Padding(
      padding: EdgeInsets.only(left: 0.w, top: 70.h),
      child: SizedBox(
        width: 63.w,
        height: 240.h,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/images/Edit_icon.svg',
                  width: 31.w,
                  height: 31.h,
                ),
                onPressed: () {
                  context.loaderOverlay.show();
                  // Handle training mode navigation
                  // ref.read(opsVMProvider.notifier).sendOpsMode(mode: 'training');
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
                onPressed: () {
                  // Handle settings navigation
                },
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
            ],
          ),
        ),
      ),
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
            left: 70.w,
            top: 100.h,
            child: Text(
              deliveryState.selectedTable != null
                  ? "Table ${deliveryState.selectedTable} selected"
                  : "Start the Service by selecting table number",
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            left: 100.w,
            right: 190.w,
            top: 218.h,
            bottom: 55.h,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight - 223.h,
                  ),
                  child: Image.asset(
                    "assets/images/alfred_base_point.png",
                    width: 1050.w,
                    height: 1054.h,
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

  Widget _buildTableSelectionSection(
      List<int> availableTables,
      DeliveryData deliveryState,
      DeliveryViewModel viewModel,
      ) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: EdgeInsets.only(top: 50.h, right: 40.w),
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
            SizedBox(height: 49.h),
            Expanded(
              child: Container(
                width: double.infinity,
                child: availableTables.isEmpty
                    ? _buildEmptyTablesMessage()
                    : _buildTableGrid(availableTables, deliveryState, viewModel),
              ),
            ),
          ],
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

  Widget _buildTableGrid(
      List<int> availableTables,
      DeliveryData deliveryState,
      DeliveryViewModel viewModel,
      ) {
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

  Widget _buildBottomActionButton(DeliveryData deliveryState, DeliveryViewModel viewModel) {
    return Positioned(
      left: 0,
      right: 40.w,
      bottom: 36.h,
      child: Padding(
        padding: EdgeInsets.only(left: 15.w),
        child: Row(
          children: [
            const Expanded(flex: 2, child: SizedBox()),
            SizedBox(width: 20.w),
            DeliveryActionButton(
              text: "Go to Table",
              isEnabled: deliveryState.selectedTable != null,
              isLoading: deliveryState.state == DeliveryState.moving,
              onPressed: () => viewModel.goToTable(),
              width: MediaQuery.of(context).size.width * 0.53,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryProgressView(DeliveryData deliveryState, DeliveryViewModel viewModel) {
    return Column(
      children: [
        AppBarWidget(),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 48.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Table Number
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 114.w,
                    maxHeight: 38.h,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Table ${deliveryState.selectedTable ?? ''}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: 0.02.w,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Status Message
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 217.w,
                    maxHeight: 29.h,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
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
                  ),
                ),

                SizedBox(height: 64.h),

                // Alfred Image
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 1050.w,
                      maxHeight: 950.h,
                    ),
                    child: Image.asset(
                      _getProgressImage(deliveryState),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Return to Base Button (only show when delivered at table)
                if (deliveryState.state == DeliveryState.delivered && deliveryState.isBaseToTable)
                  Padding(
                    padding: EdgeInsets.only(top: 32.h),
                    child: DeliveryActionButton(
                      text: "Return to Base",
                      isEnabled: true,
                      onPressed: () => viewModel.returnToBase(),
                      width: MediaQuery.of(context).size.width * 0.53,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
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
      return "assets/images/alfred_base_moving_img.png";
    } else if (deliveryState.state == DeliveryState.delivered) {
      if (deliveryState.isBaseToTable) {
        return "assets/images/alfred_arrived.png"; // At table
      } else {
        return "assets/images/alfred_base_point.png"; // Back at base
      }
    }
    return "assets/images/alfred_base_moving_img.png";
  }
}
