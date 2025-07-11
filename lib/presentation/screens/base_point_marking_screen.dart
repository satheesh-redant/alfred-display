import 'package:alfred/core/toast_utils.dart';
import 'package:alfred/view_models/base_point_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/presentation/widgets/appbar_widget.dart';
import 'package:alfred/presentation/widgets/button_widget.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../config/ros_constants.dart';
import 'save_starting_point_dialog.dart';

class BasePointMarkingScreen extends ConsumerStatefulWidget {
  const BasePointMarkingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BasePointMarkingScreenState();
}

class _BasePointMarkingScreenState
    extends ConsumerState<BasePointMarkingScreen> {
  // Track which screen to show
  bool _showMarkerScreen = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(
      basePointVMProvider,
      (previous, next) {
        print(next);
        if (next.isNotEmpty) {
          if (next.toUpperCase() == ROSConstants.success) {
            context.loaderOverlay.hide();
            ref.read(basePointVMProvider.notifier).removeResetBaseListener();
            // showSuccessToast(
            //     context: context, description: "Base Point saved successfully");
            setState(() {
              _showMarkerScreen = true;
              print('Setting _showMarkerScreen to true');
            });
          } else {
            // showErrorToast(context: context, description: next);
          }
        }
      },
    );
    if (_showMarkerScreen) {
      print('Marker screen is now showing');
      return _BasePointMarkerScreen(
        onComplete: () {
          context.go(AlfredConstants.routeTrainingScreen);
        },
      );
    }
    print('Displaying the base point marking screen');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 44),
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Mark Base Point",
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              textStyle: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Place Alfred at the Base point to start marking",
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                    // Image
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Image(
                          image: AssetImage("assets/images/base_point.png"),
                          height: 320,
                          width: 610,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Bottom Button
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 36, left: 16, right: 16),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ButtonWidget(
                            text: "I am at the Base Point",
                            onPressed: () {
                              print(
                                  'User clicked "I am at the Base Point" button');
                              showDialog(
                                context: context,
                                builder: (context) => SaveStartingPointDialog(
                                  onConfirmed: () {
                                    print(
                                        'User confirmed saving the starting point');
                                    ref.context.loaderOverlay.show();
                                    ref.read(basePointVMProvider.notifier).getResetBaseLocAck();
                                    ref.read(basePointVMProvider.notifier).resetBaseLoc();
                                    // setState(() {
                                    //   _showMarkerScreen = true;
                                    // });
                                  },
                                ),
                              );
                            },
                            isActive: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BasePointMarkerScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const _BasePointMarkerScreen({required this.onComplete});

  @override
  Widget build(BuildContext context) {
    // Navigation after delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted) {
          print('Completing the base point marking process');
          onComplete();
        }
      });
    });

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBarWidget(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageWidth = (isMobile
                    ? screenWidth * 0.9
                    : isTablet
                        ? 500.0
                        : 600.0)
                .toDouble();
            final imageHeight = imageWidth;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - kToolbarHeight,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20.0 : 40.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Text(
                            "You are at your Base Point, please move Alfred towards the table to start marking",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: isMobile ? 16.0 : 20.0,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: imageWidth,
                            maxHeight: imageHeight,
                          ),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Image.asset(
                              'assets/images/alfred_basepoint_marking.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


