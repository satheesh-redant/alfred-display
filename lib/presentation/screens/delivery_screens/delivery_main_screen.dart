
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alfred/view_models/table_view_model.dart';
import 'package:alfred/view_models/delivery_view_model.dart';
import 'package:alfred/view_models/operation_view_model.dart';
import '../../../config/alfred_constants.dart';
import '../../widgets/appbar_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../widgets/table_grid_button_widget.dart';
import '../../widgets/button_widget.dart';

class DeliveryMainScreen extends ConsumerStatefulWidget {
  const DeliveryMainScreen({super.key});

  @override
  ConsumerState<DeliveryMainScreen> createState() => _DeliveryMainScreenState();
}

class _DeliveryMainScreenState extends ConsumerState<DeliveryMainScreen> {
  final ScrollController _gridScrollController = ScrollController();

  // We manage the selected table ID locally in the screen's state.
  int? _selectedTableNumber;

  @override
  void initState() {
    super.initState();
    // Request the latest list of tables from ROS when the screen loads.
    ref.read(tableVMProvider.notifier).requestTableList();
  }

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to get the list of marked table IDs (List<int>).
    final markedTableIds = ref.watch(tableVMProvider);

    ref.listen(
      deliveryVMProvider,
          (previous, next) {
        context.loaderOverlay.hide();
        if (next == "moving") {
          // Use the locally selected table number for navigation.
          if (_selectedTableNumber != null) {
            context.push(
              '${AlfredConstants.routeDeliveryInProgressScreen}/$_selectedTableNumber',
            );
          }
        } else {
          print(next);
        }
      },
    );

    // Listener to switch to training mode
    ref.listen(opsVMProvider, (previous, next) {
      if (next.toLowerCase() == 'training') {
        ref.context.loaderOverlay.hide();
        ref.read(opsVMProvider.notifier).unsubscribe();
        context.go(AlfredConstants.routeTrainingScreen);
      }
    });
    return Scaffold(
      body: Column(
        children: [
          AppBarWidget(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar (Unchanged)
                Padding(
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
                              ref.read(opsVMProvider.notifier).sendOpsMode(mode: 'training');
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
                        ],
                      ),
                    ),
                  ),
                ),
                // Middle Section (Unchanged)
                Expanded(
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
                          "Start the Service by selecting table number",
                          style: GoogleFonts.nunito(
                            fontSize: 14.sp,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Positioned(
                        left: 122.w,
                        top: 218.h,
                        bottom: 55.h,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: constraints.maxHeight - 223.h,
                              ),
                              child: Image.asset(
                                "assets/images/alfred_base.png",
                                width: 150.w,
                                height: 814.h,
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.w, height: 36.h),
                // Table Selection Section (Modified)
                Expanded(
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
                            child: markedTableIds.isEmpty
                                ? Center(
                              child: Text(
                                "No tables marked yet\nPlease mark tables in Training Mode first",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  fontSize: 16.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                                : Scrollbar(
                              controller: _gridScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              child: GridView.builder(
                                controller: _gridScrollController,
                                shrinkWrap: false,
                                physics: const AlwaysScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 49.w.toDouble(),
                                  mainAxisSpacing: 26.h.toDouble(),
                                  childAspectRatio: (138.w / 60.h),
                                ),
                                itemCount: markedTableIds.length,
                                itemBuilder: (context, index) {
                                  final tableId = markedTableIds[index];
                                  final isSelected = tableId == _selectedTableNumber;

                                  return Padding(
                                    padding: EdgeInsets.only(right: 0.w),
                                    child: TableGridButtonWidget(
                                      label: tableId.toString(),
                                      tableNumber: tableId,
                                      isSelected: isSelected,
                                      isMarked: true, // All tables here are marked
                                      isDisabled: false, // All are selectable
                                      ignoreMarkedBackground: true,
                                      onPressed: () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedTableNumber = null;
                                          } else {
                                            _selectedTableNumber = tableId;
                                          }
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 36.h),
                        Padding(
                          padding: EdgeInsets.only(left: 15.w, right: 40.w),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final availableWidth = constraints.maxWidth; // Full available width
                              final desiredButtonWidth = 0.53 * 1280.w; // Design reference width
                              // Account for padding (15.w left + 40.w right) and spacing
                              final buttonWidth = (desiredButtonWidth < availableWidth - 55.w)
                                  ? desiredButtonWidth
                                  : availableWidth - 55.w;
                              final isTableSelected = _selectedTableNumber != null;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: ButtonWidget(
                                      text: "Go to Table",
                                      onPressed: isTableSelected
                                          ? () {
                                        context.loaderOverlay.show();
                                        ref.read(deliveryVMProvider.notifier).moveTable(table: _selectedTableNumber!);
                                        ref.read(deliveryVMProvider.notifier).deliveryStatus();
                                      }
                                          : null,
                                      isActive: isTableSelected,
                                      width: buttonWidth,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 36.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}