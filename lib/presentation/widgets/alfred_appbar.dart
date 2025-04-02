import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

// First define the state class
class AlfredAppBarState {
  final String currentTime;

  AlfredAppBarState({
    this.currentTime = "",
  });

  AlfredAppBarState copyWith({
    String? currentTime,
  }) {
    return AlfredAppBarState(
      currentTime: currentTime ?? this.currentTime,
    );
  }
}

// Then define the StateNotifier
class AlfredAppBarStateNotifier extends StateNotifier<AlfredAppBarState> {
  AlfredAppBarStateNotifier() : super(AlfredAppBarState()) {
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

// Define the provider next
final alfredAppBarProvider = StateNotifierProvider<AlfredAppBarStateNotifier, AlfredAppBarState>(
      (ref) => AlfredAppBarStateNotifier(),
);

// Then define the widget that uses the provider
class AlfredAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(35);

  static double _scaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 1.3;
    if (width > 600) return 1.1;
    return 1.0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alfredAppBarProvider);
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
            // This ensures perfect vertical centering within app bar
            alignment: Alignment.center,
            child: Image.asset(
              "assets/images/company_logo.png",
              width: 15 * scale,
              height: 20 * scale,
              fit: BoxFit.contain,
            ),
          ),

          SizedBox(width: 20 * scale),
          Text(
            state.currentTime,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF101828),
              fontFamily: 'Inter',
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
                margin: EdgeInsets.only(right: 10 * scale),
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
              Container(
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
