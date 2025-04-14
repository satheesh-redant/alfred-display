import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
final appBarWidgetProvider = StateNotifierProvider<AppBarWidgetStateNotifier, AppBarWidgetState>(
      (ref) => AppBarWidgetStateNotifier(),
);

// Widget
class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(35);

  const AppBarWidget({super.key});

  static double _scaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 1.3;
    if (width > 600) return 1.1;
    return 1.0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appBarWidgetProvider); // Now this will work
    final scale = _scaleFactor(context);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.grey[300],
      toolbarHeight: 35 * scale,
      title: Row(
        children: [
          Container(
            width: 15 * scale,
            height: 22.41 * scale,
            margin: EdgeInsets.only(left: 10 * scale),
            alignment: Alignment.center,
            child: Image.asset(
              "assets/images/company_logo.png",
              width: 15 * scale,
              height: 18 * scale,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 20 * scale),
          Text(
            state.currentTime,
            style: GoogleFonts.inter(
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF101828),
              height: 29/(14 * scale),
              letterSpacing: 0.01 * scale,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 10 * scale),
          child: Row(
            children: [
              Container(
                width: 32 * scale,
                height: 32 * scale,
                margin: EdgeInsets.only(right: 5 * scale),
                child: InkWell(
                  onTap: () {},
                  child: SvgPicture.asset(
                    "assets/images/wifi_icon.svg",
                    width: 24 * scale,
                    height: 24 * scale,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
              SizedBox(
                width: 32 * scale,
                height: 32 * scale,
                child: InkWell(
                  onTap: null,
                  child: SvgPicture.asset(
                    "assets/images/dark_mode_icon.svg",
                    width: 24 * scale,
                    height: 24 * scale,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
