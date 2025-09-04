import 'dart:async';
import 'package:alfred/config/assets_constants.dart';
import 'package:alfred/presentation/widgets/widget_battery.dart';
import 'package:alfred/view_models/battery_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_framework/responsive_framework.dart';

// State class
class AppBarWidgetState {
  final String currentTime;

  AppBarWidgetState({
    this.currentTime = "",
  });

  AppBarWidgetState copyWith({
    String? currentTime,
  }) {
    return AppBarWidgetState(
      currentTime: currentTime ?? this.currentTime,
    );
  }
}

// StateNotifier
class AppBarWidgetStateNotifier extends StateNotifier<AppBarWidgetState> {
  AppBarWidgetStateNotifier() : super(AppBarWidgetState()) {
    _init();
  }

  Timer? _timer;

  void _init() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final timeString = DateFormat('h:mm').format(now);
    final period = now.hour < 12 ? 'am' : 'pm';
    final dateString = DateFormat('d MMMM').format(now);

    state = state.copyWith(
      currentTime: '$timeString $period, $dateString',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Provider (make sure this is declared as final and globally accessible)
final appBarWidgetProvider =
    StateNotifierProvider<AppBarWidgetStateNotifier, AppBarWidgetState>(
  (ref) => AppBarWidgetStateNotifier(),
);

// Widget
class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(40.0);

  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appBarWidgetProvider);
    final batteryState = ref.watch(batteryVMProvider);
    return Container(
      color: const Color(0xFFFFFFFF),
      child: ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.COLUMN,
        columnMainAxisAlignment: MainAxisAlignment.center,
        children: [
          ResponsiveRowColumnItem(
              child: ResponsiveRowColumn(
            layout: ResponsiveRowColumnType.ROW,
            children: [
              ResponsiveRowColumnItem(
                  child: ResponsiveRowColumn(
                layout: ResponsiveRowColumnType.ROW,
                rowMainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ResponsiveRowColumnItem(
                      child: Padding(
                    padding: EdgeInsets.only(left: 20, top: 5, bottom: 5),
                    child: Image.asset(
                      AssetsConstants.companyLogo,
                      width: 15,
                      height: 20,
                      fit: BoxFit.cover,
                    ),
                  )),
                  ResponsiveRowColumnItem(
                      child: Padding(
                    padding: EdgeInsets.only(left: 27, top: 9, bottom: 9),
                    child: Text(
                      state.currentTime,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101828),
                      ),
                    ),
                  ))
                ],
              )),
              ResponsiveRowColumnItem(child: Spacer()),
              ResponsiveRowColumnItem(
                  child: ResponsiveRowColumn(
                layout: ResponsiveRowColumnType.ROW,
                children: [
                  ResponsiveRowColumnItem(
                      child: Padding(
                    padding: EdgeInsets.only(right: 18),
                    child: InkWell(
                      onTap: () {},
                      child: SvgPicture.asset(
                        AssetsConstants.iconWifi,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )),
                  ResponsiveRowColumnItem(
                      child: WidgetBattery(batteryStatus: batteryState)
                  ),
                ],
              )),
            ],
          )),
        ],
      ),
    );
  }
}
