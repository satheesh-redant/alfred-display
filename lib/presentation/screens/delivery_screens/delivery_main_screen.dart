import 'package:alfred/models/route_state.dart';
import 'package:alfred/view_models/operation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alfred/providers/table_providers.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../../config/alfred_constants.dart';
import '../../../view_models/delivery_view_model.dart';
import '../../../view_models/table_view_model.dart';
import '../../widgets/appbar_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/table_grid_button_widget.dart';
import '../../widgets/button_widget.dart';

final deliveryScreenTableProvider = StateProvider<RouteState?>((ref) => null);

class DeliveryMainScreen extends ConsumerStatefulWidget {
  const DeliveryMainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DeliveryMainScreenState();
}

class _DeliveryMainScreenState extends ConsumerState<DeliveryMainScreen> {

  int selectedTableNumber = -1;

  @override
  void initState() {
    super.initState();
    ref.read(tableVMProvider.notifier).requestTableList();
  }

  @override
  Widget build(BuildContext context) {
    final allTables = ref.watch(tableProvider);
    final markedTables = ref.watch(markedTablesProvider);
    final selectedTable = ref.watch(deliveryScreenTableProvider);

    ref.listen(
      deliveryVMProvider,
      (previous, next) {
        if (next == "moving" && selectedTable?.route != -1) {
          context
              .pushReplacement(AlfredConstants.routeDeliveryInProgressScreen);
        }
      },
    );

    ref.listen(
      opsVMProvider,
      (previous, next) {
        if (next.toLowerCase() == 'training') {
          ref.read(opsVMProvider.notifier).unsubscribe();
          context.loaderOverlay.hide();
          context.go(AlfredConstants.routeChecklistScreen);
        }
      },
    );

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AppBarWidget(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 0, top: 70),
                      child: Container(
                        width: 63,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/images/Edit_icon.svg',
                                width: 31,
                                height: 31,
                              ),
                              onPressed: () {
                                context.loaderOverlay.show();
                                ref
                                    .read(opsVMProvider.notifier)
                                    .sendOpsMode(mode: 'training');
                              },
                            ),
                            Center(
                              child: Text(
                                'Training \nMode',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.20,
                                  letterSpacing: 0.24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/images/setting_icon.svg',
                                width: 36,
                                height: 36,
                              ),
                              onPressed: () {},
                            ),
                            Text(
                              "Settings",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.20,
                                letterSpacing: 0.24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/images/setting_icon.svg',
                                width: 36,
                                height: 36,
                              ),
                              onPressed: () {
                                if(selectedTableNumber != -1) {
                                  ref.read(deliveryScreenTableProvider.notifier)
                                      .state =
                                      RouteState(
                                          tableNumber: selectedTableNumber,
                                          route: -1);
                                  ref.read(deliveryVMProvider.notifier).moveTable(
                                      table: selectedTableNumber, route: 1);
                                }
                              },
                            ),
                            Text(
                              "Base",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.20,
                                letterSpacing: 0.24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 183,
                            top: 50,
                            child: Text(
                              "Alfred at Base",
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            left: 111,
                            top: 100,
                            child: Text(
                              "Start the Service by selecting table number",
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            left: 122,
                            top: 218,
                            bottom: 5,
                            child: Image.asset(
                              "assets/images/alfred_base.png",
                              width: 267,
                              height: 614,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Select Tables",
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 49),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(right: 40),
                              child: ref.watch(tableVMProvider).isEmpty
                                  ? Center(
                                      child: Text(
                                        "No tables marked yet\nPlease mark tables in Training Mode first",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 49,
                                        mainAxisSpacing: 26,
                                        childAspectRatio: 138 / 60,
                                      ),
                                      itemCount:
                                          ref.watch(tableVMProvider).length,
                                      itemBuilder: (context, index) {
                                        final data = ref.watch(tableVMProvider);
                                        final isSelected =
                                            selectedTableNumber ==
                                                data[index];
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right: index % 4 == 3 ? 0 : 0,
                                          ),
                                          child: TableGridButtonWidget(
                                            label: data[index].toString(),
                                            tableNumber: data[index],
                                            isSelected: isSelected,
                                            onPressed: () {
                                              setState(() {
                                                selectedTableNumber = data[index];
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 40,
            bottom: 36,
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: SizedBox(),
                  ),
                  const SizedBox(width: 20),
                  ButtonWidget(
                    text: "Go to Table",
                    onPressed: () {
                      ref.read(deliveryScreenTableProvider.notifier)
                          .state =
                          RouteState(
                              tableNumber: selectedTableNumber,
                              route: 0);
                      ref.read(deliveryVMProvider.notifier).moveTable(
                          table: selectedTableNumber,
                          route: 0);
                    },
                    isActive: selectedTableNumber != -1,
                    width: MediaQuery.of(context).size.width * 0.53,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
