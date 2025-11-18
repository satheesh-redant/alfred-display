import 'package:alfred/core/toast_utils.dart';
import 'package:alfred/models/battery_state.dart';
import 'package:alfred/models/route_state.dart';
import 'package:alfred/view_models/operation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../../config/alfred_constants.dart';
import '../../../view_models/battery_view_model.dart';
import '../../../view_models/delivery_view_model.dart';
import '../../../view_models/ros_connection_view_model.dart';
import '../../../view_models/table_view_model.dart';
import '../../widgets/widget_appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:slider_button/slider_button.dart';

import '../confirmation_dialog.dart';

final deliveryScreenTableProvider = StateProvider<RouteState?>((ref) => null);

class DeliveryMainScreen extends ConsumerStatefulWidget {
  const DeliveryMainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeliveryMainScreenState();
}

class _DeliveryMainScreenState extends ConsumerState<DeliveryMainScreen> {
  int selectedTableNumber = -1;

  List<int> tables = List.generate(10, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    ref.read(tableVMProvider.notifier).requestTableList();
  }

  @override
  Widget build(BuildContext context) {
    final batteryState = ref.watch(batteryViewModelProvider);
    final tableList = ref.watch(tableVMProvider);
    if (tableList.isNotEmpty) {
      tables = tableList;
    }

    ref.listen(
      deliveryVMProvider,
      (previous, next) {
        if (next.toLowerCase() == "moving") {
          ref.read(deliveryScreenTableProvider.notifier).state = RouteState(
              tableNumber: selectedTableNumber, status: Status.inprogress);

          context
              .pushReplacement(AlfredConstants.routeDeliveryInProgressScreen);
        } else {
          showErrorToast(context: context, description: next);
        }
      },
    );

    ref.listen(rosConnectionVMProvider, (previous, next) {
      if (next == ConnectionStatus.connecting) {
        context.loaderOverlay.show();
      } else {
        context.loaderOverlay.hide();
        ref.read(opsVMProvider.notifier).getCurrentMode();
      }
    });

    ref.listen(
      opsVMProvider,
      (previous, next) {
        if (next.isNotEmpty) {
          context.loaderOverlay.hide();
          ref.read(opsVMProvider.notifier).unsubscribe();
          if (next.toLowerCase() == 'mapping') {
            context.go(AlfredConstants.routeTrainingScreen);
          } else {
            print(next.toLowerCase());
          }
        }
      },
    );

    // power off slider
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
                    context.go(AlfredConstants.routeSoftShutdownScreen);
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
                  height: 60,        // FIXED (must be >= 60)
                  buttonSize: 60,    // Explicitly set
                  buttonColor: Colors.red,
                  backgroundColor: Colors.grey.shade200,
                  baseColor: Colors.black,
                  highlightedColor: Colors.red.shade700,
                )
                ,
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Light background
      appBar: AlfredAppBarWidget(showBackButton: false),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Main content
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, left: 100),
                    // Add left margin for sidebar space
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Center - Alfred Image and Status
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 30),
                                Text(
                                  "Alfred at Base",
                                  style: GoogleFonts.nunito(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF2E3A59),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  "Start the Service by selecting table number",
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 30),
                                Expanded(
                                  child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 300),
                                    child: Image.asset(
                                      "assets/images/alfred_base.png",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right Side - Table Selection Card
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.only(top: 20, right: 20),
                            child: _buildTableSelectionCard(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Left Sidebar - Positioned at center left
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF2E3A59),
                              const Color(0xFF1A2332),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Training Mode
                            _buildSidebarItem(
                              icon: Icons.school_outlined,
                              label: 'Training\nMode',
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ConfirmationDialog(
                                      title: "Alert !",
                                      message:
                                          "Are you sure you want to start Training Mode?",
                                      onYes: () {
                                        print("User confirmed mapping");
                                        context.loaderOverlay.show();
                                        ref
                                            .read(opsVMProvider.notifier)
                                            .sendOpsMode(mode: "mapping");
                                      },
                                      onNo: () {
                                        print("User cancelled routing");
                                      },
                                    );
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // Settings
                            _buildSidebarItem(
                              icon: Icons.settings_outlined,
                              label: 'Settings',
                              onTap: () {
                                // Settings action
                              },
                            ),

                            // 🔹 Added white divider line below settings
                            const SizedBox(height: 10),
                            Container(
                              height: 1,
                              width: 40,
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 10),
                            ),

                            const SizedBox(height: 10),

                            _buildSidebarItem(
                              icon: Icons.power_settings_new_outlined,
                              label: 'Power Off',
                              onTap: () {
                                _showPowerOffDialog();
                              },
                              isPowerButton: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    bool isPowerButton = false, // Added for Power Off style
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isPowerButton
                ? Colors.white // white background for Power Off
                : isActive
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: isPowerButton
                    ? Colors.red // red icon for Power Off
                    : Colors.white,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: isPowerButton
                      ? Colors.red // red text for Power Off
                      : Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableSelectionCard() {
    return Card(
      elevation: 6,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  // Grid for tables
                  Expanded(
                    child: tables.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[21],
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    Icons.table_restaurant_outlined,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "No tables marked yet",
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Please mark tables in Training Mode first",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.8,
                            ),
                            itemCount: tables.length,
                            itemBuilder: (context, index) {
                              final tableNumber = tables[index];
                              final isSelected =
                                  selectedTableNumber == tableNumber;

                              return _buildTableButton(
                                tableNumber: tableNumber,
                                isSelected: isSelected,
                                onPressed: () {
                                  setState(() {
                                    selectedTableNumber = tableNumber;
                                  });
                                },
                              );
                            },
                          ),
                  ),

                  // Action Button inside the card
                  if (selectedTableNumber != -1) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade600, // Changed to blue
                            Colors.blue.shade700, // Changed to blue
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            // Changed to blue
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          final batteryState =
                              ref.read(batteryViewModelProvider).value;
                          final percentage =
                              (batteryState?.percentage ?? 0) * 100;
                          final category =
                              ref.read(batteryLevelCategoryProvider);
                          final isCharging = batteryState?.statusEnum ==
                              BatteryStatus.charging;

                          // Don't show alerts when charging (already on charging screen)
                          if (isCharging) {
                            return;
                          }

                          if (category == BatteryLevelCategory.criticalLow &&
                              percentage >= 5 &&
                              percentage < 10) {
                            // Use WidgetsBinding to ensure dialog shows after build completes
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _showCriticalWarningDialog(batteryState!);
                            });
                            return;
                          }

                          if (category == BatteryLevelCategory.criticalLow &&
                              percentage < 5) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _showCriticalConfirmationDialog(batteryState!);
                            });
                            return;
                          }
                          _triggerDelivery();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Go to Table $selectedTableNumber",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableButton({
    required int tableNumber,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1), // Changed to blue
                    Colors.blue.withOpacity(0.05), // Changed to blue
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            // Changed to blue
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2), // Changed to blue
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_restaurant_rounded,
                size: 20,
                color: isSelected
                    ? Colors.blue
                    : Colors.grey.shade600, // Changed to blue
              ),
              const SizedBox(height: 4),
              Text(
                tableNumber.toString(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.blue
                      : Colors.black87, // Changed to blue
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCriticalConfirmationDialog(BatteryState battery) {
    if (!mounted) return;

    final estimatedTime =
        ref.read(batteryViewModelProvider.notifier).estimatedMinutesLeft;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        actionsPadding: const EdgeInsets.only(bottom: 24),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Battery Icon
            SvgPicture.asset(
              'assets/images/icon_critical_low_battery.svg',
              // Path to your SVG file
              width: 143,
              height: 143,
            ),
            const SizedBox(height: 16),

            Text(
              'Critically Low Battery < 10%',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF040303),
                fontWeight: FontWeight.w400,
                height: 1.0, // Removes extra vertical space from text
              ),
              textAlign: TextAlign.center,
            ),
            // const SizedBox(height: 12),
            // Text(
            //   'Estimated Run Time: ${estimatedTime ?? 20} min',
            //   style: GoogleFonts.inter(
            //     fontSize: 24,
            //     color: const Color(0xFF000000),
            //     fontWeight: FontWeight.w600,
            //     height: 1.0, // Removes extra vertical space from text
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 16),
            Text(
              'Please plug in the charger to avoid shutdown',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0x9F040303),
                fontWeight: FontWeight.w400,
                height: 1.0, // Removes extra vertical space from text
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
        ),
        actions: [
          Align(
              alignment: AlignmentGeometry.center,
              child: SizedBox(
                width: 160,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF005AFF),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        // Changed to blue
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Okay",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showCriticalWarningDialog(BatteryState battery) {
    if (!mounted) return;

    final estimatedTime =
        ref.read(batteryViewModelProvider.notifier).estimatedMinutesLeft;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        actionsPadding: const EdgeInsets.only(bottom: 24),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Battery Icon
            SvgPicture.asset(
              'assets/images/icon_critical_low_battery.svg',
              // Path to your SVG file
              width: 143,
              height: 143,
            ),
            const SizedBox(height: 16),

            Text(
              'Are you sure you want to continue for service ?',
              style: GoogleFonts.inter(
                fontSize: 20,
                color: const Color(0xFF000000),
                fontWeight: FontWeight.w400,
                height: 1.0, // Removes extra vertical space from text
              ),
              textAlign: TextAlign.center,
            ),
            // const SizedBox(height: 12),
            // Text(
            //   'Estimated Run Time: ${estimatedTime ?? 20} min',
            //   style: GoogleFonts.inter(
            //     fontSize: 24,
            //     color: const Color(0xFF000000),
            //     fontWeight: FontWeight.w600,
            //     height: 1.0, // Removes extra vertical space from text
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 30),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 160,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: Color(0xFF005AFF),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _triggerDelivery();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Color(0xFF005AFF),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Yes",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF005AFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 24),

              SizedBox(
                width: 160,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFF005AFF),
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        // Changed to blue
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _triggerDelivery() {
    ref.read(deliveryScreenTableProvider.notifier).state =
        RouteState(tableNumber: selectedTableNumber, status: Status.pending);
    ref.read(deliveryVMProvider.notifier).moveTable(table: selectedTableNumber);
  }
}
// // // slider
// //
// import 'package:alfred/core/toast_utils.dart';
// import 'package:alfred/models/battery_state.dart';
// import 'package:alfred/models/route_state.dart';
// import 'package:alfred/view_models/operation_view_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:loader_overlay/loader_overlay.dart';
// import '../../../config/alfred_constants.dart';
// import '../../../view_models/battery_view_model.dart';
// import '../../../view_models/delivery_view_model.dart';
// import '../../../view_models/ros_connection_view_model.dart';
// import '../../../view_models/table_view_model.dart';
// import '../../widgets/widget_appbar.dart';
// import 'package:go_router/go_router.dart';
// import 'package:slider_button/slider_button.dart';
// import '../confirmation_dialog.dart';
//
// final deliveryScreenTableProvider = StateProvider<RouteState?>((ref) => null);
//
// class DeliveryMainScreen extends ConsumerStatefulWidget {
//   const DeliveryMainScreen({super.key});
//
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _DeliveryMainScreenState();
// }
//
// class _DeliveryMainScreenState extends ConsumerState<DeliveryMainScreen> {
//   int selectedTableNumber = -1;
//
//   List<int> tables = List.generate(10, (index) => index + 1);
//
//   @override
//   void initState() {
//     super.initState();
//     ref.read(tableVMProvider.notifier).requestTableList();
//   }
//
//
//   void _showPowerOffDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           surfaceTintColor: Colors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
//           actionsPadding: const EdgeInsets.only(bottom: 24),
//           insetPadding: const EdgeInsets.symmetric(horizontal: 40),
//
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.power_settings_new_rounded,
//                 size: 70,
//                 color: Colors.red,
//               ),
//               const SizedBox(height: 20),
//
//               Text(
//                 "Are you sure you want to\npower off Alfred?",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.inter(
//                   fontSize: 18,
//                   color: Colors.black,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//
//               const SizedBox(height: 30),
//             ],
//           ),
//
//           actions: [
//             Center(
//               child: SliderButton(
//         action: () async {
//           Navigator.pop(context);
//           context.go(AlfredConstants.routeSoftShutdownScreen);
//           return true;
//         },
//
//         label: Text(
//         "Slide to Power Off",
//         style: TextStyle(
//         color: Colors.black87,
//         fontSize: 15,
//         fontWeight: FontWeight.w600,
//         ),
//         ),
//
//         icon: Icon(Icons.power_settings_new, color: Colors.white),
//
//         width: 250,
//         height: 60,        // FIXED (must be >= 60)
//         buttonSize: 60,    // Explicitly set
//         buttonColor: Colors.red,
//         backgroundColor: Colors.grey.shade200,
//         baseColor: Colors.black,
//         highlightedColor: Colors.red.shade700,
//         )
//
//         ,
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final batteryState = ref.watch(batteryViewModelProvider);
//     final tableList = ref.watch(tableVMProvider);
//     if (tableList.isNotEmpty) {
//       tables = tableList;
//     }
//
//     ref.listen(
//       deliveryVMProvider,
//           (previous, next) {
//         if (next.toLowerCase() == "moving") {
//           ref.read(deliveryScreenTableProvider.notifier).state = RouteState(
//               tableNumber: selectedTableNumber, status: Status.inprogress);
//
//           context
//               .pushReplacement(AlfredConstants.routeDeliveryInProgressScreen);
//         } else {
//           showErrorToast(context: context, description: next);
//         }
//       },
//     );
//
//     ref.listen(rosConnectionVMProvider, (previous, next) {
//       if (next == ConnectionStatus.connecting) {
//         context.loaderOverlay.show();
//       } else {
//         context.loaderOverlay.hide();
//         ref.read(opsVMProvider.notifier).getCurrentMode();
//       }
//     });
//
//     ref.listen(
//       opsVMProvider,
//           (previous, next) {
//         if (next.isNotEmpty) {
//           context.loaderOverlay.hide();
//           ref.read(opsVMProvider.notifier).unsubscribe();
//           if (next.toLowerCase() == 'mapping') {
//             context.go(AlfredConstants.routeTrainingScreen);
//           } else {
//             print(next.toLowerCase());
//           }
//         }
//       },
//     );
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFFFFF), // Light background
//       appBar: AlfredAppBarWidget(showBackButton: false),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: Stack(
//                 children: [
//                   // Main content
//                   Container(
//                     margin: const EdgeInsets.only(bottom: 20, left: 100),
//                     // Add left margin for sidebar space
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Center - Alfred Image and Status
//                         Expanded(
//                           flex: 2,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 20),
//                             child: Column(
//                               children: [
//                                 const SizedBox(height: 30),
//                                 Text(
//                                   "Alfred at Base",
//                                   style: GoogleFonts.nunito(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.w900,
//                                     color: const Color(0xFF2E3A59),
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 const SizedBox(height: 15),
//                                 Text(
//                                   "Start the Service by selecting table number",
//                                   style: GoogleFonts.nunito(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.grey,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                                 const SizedBox(height: 30),
//                                 Expanded(
//                                   child: Container(
//                                     constraints:
//                                     const BoxConstraints(maxWidth: 300),
//                                     child: Image.asset(
//                                       "assets/images/alfred_base.png",
//                                       fit: BoxFit.contain,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         // Right Side - Table Selection Card
//                         Expanded(
//                           flex: 3,
//                           child: Container(
//                             margin: const EdgeInsets.only(top: 20, right: 20),
//                             child: _buildTableSelectionCard(),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Left Sidebar - Positioned at center left
//                   Positioned(
//                     left: 20,
//                     top: 0,
//                     bottom: 0,
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Container(
//                         width: 80,
//                         padding: const EdgeInsets.symmetric(vertical: 20),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               const Color(0xFF2E3A59),
//                               const Color(0xFF1A2332),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 8,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             // Training Mode
//                             _buildSidebarItem(
//                               icon: Icons.school_outlined,
//                               label: 'Training\nMode',
//                               onTap: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return ConfirmationDialog(
//                                       title: "Alert !",
//                                       message:
//                                       "Are you sure you want to start Training Mode?",
//                                       onYes: () {
//                                         print("User confirmed mapping");
//                                         context.loaderOverlay.show();
//                                         ref
//                                             .read(opsVMProvider.notifier)
//                                             .sendOpsMode(mode: "mapping");
//                                       },
//                                       onNo: () {
//                                         print("User cancelled routing");
//                                       },
//                                     );
//                                   },
//                                 );
//                               },
//                             ),
//
//                             const SizedBox(height: 20),
//
//                             // Settings
//                             _buildSidebarItem(
//                               icon: Icons.settings_outlined,
//                               label: 'Settings',
//                               onTap: () {
//                                 // Settings action
//                               },
//                             ),
//
//                             // 🔹 Added white divider line below settings
//                             const SizedBox(height: 10),
//                             Container(
//                               height: 1,
//                               width: 40,
//                               color: Colors.white,
//                               margin: const EdgeInsets.only(bottom: 10),
//                             ),
//
//                             const SizedBox(height: 10),
//
//                             _buildSidebarItem(
//                               icon: Icons.power_settings_new_outlined,
//                               label: 'Power Off',
//                               onTap: () {
//                                _showPowerOffDialog();
//                               },
//                               isPowerButton: true,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSidebarItem({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//     bool isActive = false,
//     bool isPowerButton = false, // Added for Power Off style
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: 60,
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           decoration: BoxDecoration(
//             color: isPowerButton
//                 ? Colors.white // white background for Power Off
//                 : isActive
//                 ? Colors.white.withOpacity(0.2)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 icon,
//                 size: 24,
//                 color: isPowerButton
//                     ? Colors.red // red icon for Power Off
//                     : Colors.white,
//               ),
//               const SizedBox(height: 6),
//               Text(
//                 label,
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.nunito(
//                   color: isPowerButton
//                       ? Colors.red // red text for Power Off
//                       : Colors.white,
//                   fontSize: 9,
//                   fontWeight: FontWeight.w600,
//                   height: 1.1,
//                   letterSpacing: 0.2,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTableSelectionCard() {
//     return Card(
//       elevation: 6,
//       color: Colors.white,
//       surfaceTintColor: Colors.transparent,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Column(
//                 children: [
//                   // Grid for tables
//                   Expanded(
//                     child: tables.isEmpty
//                         ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: Colors.grey[21],
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             child: Icon(
//                               Icons.table_restaurant_outlined,
//                               size: 48,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           Text(
//                             "No tables marked yet",
//                             style: GoogleFonts.nunito(
//                               fontSize: 18,
//                               color: Colors.grey,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             "Please mark tables in Training Mode first",
//                             textAlign: TextAlign.center,
//                             style: GoogleFonts.nunito(
//                               fontSize: 14,
//                               color: Colors.grey,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )
//                         : GridView.builder(
//                       gridDelegate:
//                       const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 4,
//                         crossAxisSpacing: 12,
//                         mainAxisSpacing: 12,
//                         childAspectRatio: 1.8,
//                       ),
//                       itemCount: tables.length,
//                       itemBuilder: (context, index) {
//                         final tableNumber = tables[index];
//                         final isSelected =
//                             selectedTableNumber == tableNumber;
//
//                         return _buildTableButton(
//                           tableNumber: tableNumber,
//                           isSelected: isSelected,
//                           onPressed: () {
//                             setState(() {
//                               selectedTableNumber = tableNumber;
//                             });
//                           },
//                         );
//                       },
//                     ),
//                   ),
//
//                   // Action Button inside the card
//                   if (selectedTableNumber != -1) ...[
//                     const SizedBox(height: 20),
//                     Container(
//                       width: double.infinity,
//                       height: 50,
//                       margin: const EdgeInsets.only(bottom: 10),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             Colors.blue.shade600, // Changed to blue
//                             Colors.blue.shade700, // Changed to blue
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.blue.withOpacity(0.3),
//                             // Changed to blue
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: ElevatedButton(
//                         onPressed: () {
//                           final batteryState =
//                               ref.read(batteryViewModelProvider).value;
//                           final percentage =
//                               (batteryState?.percentage ?? 0) * 100;
//                           final category =
//                           ref.read(batteryLevelCategoryProvider);
//                           final isCharging = batteryState?.statusEnum ==
//                               BatteryStatus.charging;
//
//                           // Don't show alerts when charging (already on charging screen)
//                           if (isCharging) {
//                             return;
//                           }
//
//                           if (category == BatteryLevelCategory.criticalLow &&
//                               percentage >= 5 &&
//                               percentage < 10) {
//                             // Use WidgetsBinding to ensure dialog shows after build completes
//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               _showCriticalWarningDialog(batteryState!);
//                             });
//                             return;
//                           }
//
//                           if (category == BatteryLevelCategory.criticalLow &&
//                               percentage < 5) {
//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               _showCriticalConfirmationDialog(batteryState!);
//                             });
//                             return;
//                           }
//                           _triggerDelivery();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.transparent,
//                           foregroundColor: Colors.white,
//                           elevation: 0,
//                           shadowColor: Colors.transparent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(Icons.arrow_forward_rounded, size: 20),
//                             const SizedBox(width: 8),
//                             Text(
//                               "Go to Table $selectedTableNumber",
//                               style: GoogleFonts.inter(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTableButton({
//     required int tableNumber,
//     required bool isSelected,
//     required VoidCallback onPressed,
//   }) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           gradient: isSelected
//               ? LinearGradient(
//             colors: [
//               Colors.blue.withOpacity(0.1), // Changed to blue
//               Colors.blue.withOpacity(0.05), // Changed to blue
//             ],
//           )
//               : null,
//           color: isSelected ? null : Colors.grey.shade50,
//           border: Border.all(
//             color: isSelected ? Colors.blue : Colors.grey.shade300,
//             // Changed to blue
//             width: isSelected ? 2 : 1,
//           ),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: isSelected
//               ? [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.2), // Changed to blue
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ]
//               : null,
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.table_restaurant_rounded,
//                 size: 20,
//                 color: isSelected
//                     ? Colors.blue
//                     : Colors.grey.shade600, // Changed to blue
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 tableNumber.toString(),
//                 style: GoogleFonts.inter(
//                   fontSize: 12,
//                   fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//                   color: isSelected
//                       ? Colors.blue
//                       : Colors.black87, // Changed to blue
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showCriticalConfirmationDialog(BatteryState battery) {
//     if (!mounted) return;
//
//     final estimatedTime =
//         ref.read(batteryViewModelProvider.notifier).estimatedMinutesLeft;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
//         actionsPadding: const EdgeInsets.only(bottom: 24),
//         insetPadding: const EdgeInsets.symmetric(horizontal: 40),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Battery Icon
//             SvgPicture.asset(
//               'assets/images/icon_critical_low_battery.svg',
//               // Path to your SVG file
//               width: 143,
//               height: 143,
//             ),
//             const SizedBox(height: 16),
//
//             Text(
//               'Critically Low Battery < 10%',
//               style: GoogleFonts.inter(
//                 fontSize: 16,
//                 color: const Color(0xFF040303),
//                 fontWeight: FontWeight.w400,
//                 height: 1.0, // Removes extra vertical space from text
//               ),
//               textAlign: TextAlign.center,
//             ),
//             // const SizedBox(height: 12),
//             // Text(
//             //   'Estimated Run Time: ${estimatedTime ?? 20} min',
//             //   style: GoogleFonts.inter(
//             //     fontSize: 24,
//             //     color: const Color(0xFF000000),
//             //     fontWeight: FontWeight.w600,
//             //     height: 1.0, // Removes extra vertical space from text
//             //   ),
//             //   textAlign: TextAlign.center,
//             // ),
//             const SizedBox(height: 16),
//             Text(
//               'Please plug in the charger to avoid shutdown',
//               style: GoogleFonts.inter(
//                 fontSize: 16,
//                 color: const Color(0x9F040303),
//                 fontWeight: FontWeight.w400,
//                 height: 1.0, // Removes extra vertical space from text
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//         actions: [
//           Align(
//               alignment: AlignmentGeometry.center,
//               child: SizedBox(
//                 width: 160,
//                 child: Container(
//                   width: double.infinity,
//                   height: 50,
//                   margin: const EdgeInsets.only(bottom: 10),
//                   decoration: BoxDecoration(
//                     color: Color(0xFF005AFF),
//                     borderRadius: BorderRadius.circular(7),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.3),
//                         // Changed to blue
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Okay",
//                           style: GoogleFonts.inter(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
//
//   void _showCriticalWarningDialog(BatteryState battery) {
//     if (!mounted) return;
//
//     final estimatedTime =
//         ref.read(batteryViewModelProvider.notifier).estimatedMinutesLeft;
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
//         actionsPadding: const EdgeInsets.only(bottom: 24),
//         insetPadding: const EdgeInsets.symmetric(horizontal: 40),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Battery Icon
//             SvgPicture.asset(
//               'assets/images/icon_critical_low_battery.svg',
//               // Path to your SVG file
//               width: 143,
//               height: 143,
//             ),
//             const SizedBox(height: 16),
//
//             Text(
//               'Are you sure you want to continue for service ?',
//               style: GoogleFonts.inter(
//                 fontSize: 20,
//                 color: const Color(0xFF000000),
//                 fontWeight: FontWeight.w400,
//                 height: 1.0, // Removes extra vertical space from text
//               ),
//               textAlign: TextAlign.center,
//             ),
//             // const SizedBox(height: 12),
//             // Text(
//             //   'Estimated Run Time: ${estimatedTime ?? 20} min',
//             //   style: GoogleFonts.inter(
//             //     fontSize: 24,
//             //     color: const Color(0xFF000000),
//             //     fontWeight: FontWeight.w600,
//             //     height: 1.0, // Removes extra vertical space from text
//             //   ),
//             //   textAlign: TextAlign.center,
//             // ),
//             const SizedBox(height: 30),
//           ],
//         ),
//         actions: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(
//                 width: 160,
//                 child: Container(
//                   width: double.infinity,
//                   height: 50,
//                   margin: const EdgeInsets.only(bottom: 10),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(7),
//                     border: Border.all(
//                       color: Color(0xFF005AFF),
//                       width: 1,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.3),
//                         blurRadius: 4,
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _triggerDelivery();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       foregroundColor: Color(0xFF005AFF),
//                       elevation: 0,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(7),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Yes",
//                           style: GoogleFonts.inter(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF005AFF),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(width: 24),
//
//               SizedBox(
//                 width: 160,
//                 child: Container(
//                   width: double.infinity,
//                   height: 50,
//                   margin: const EdgeInsets.only(bottom: 10),
//                   decoration: BoxDecoration(
//                     color: Color(0xFF005AFF),
//                     borderRadius: BorderRadius.circular(7),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.blue.withOpacity(0.3),
//                         // Changed to blue
//                         blurRadius: 4,
//                       ),
//                     ],
//                   ),
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.transparent,
//                       foregroundColor: Colors.white,
//                       elevation: 0,
//                       shadowColor: Colors.transparent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(7),
//                       ),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "No",
//                           style: GoogleFonts.inter(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
//
//   void _triggerDelivery() {
//     ref.read(deliveryScreenTableProvider.notifier).state =
//         RouteState(tableNumber: selectedTableNumber, status: Status.pending);
//     ref.read(deliveryVMProvider.notifier).moveTable(table: selectedTableNumber);
//   }
// }
//
