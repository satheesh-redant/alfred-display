import 'package:alfred/presentation/screens/save_starting_point_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/appbar_widget.dart';
import '../widgets/bottom_button_widget.dart'; // Import the BottomActionButton

class BasePointScreen extends ConsumerStatefulWidget {
  const BasePointScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BasePointScreenState();
}

class _BasePointScreenState extends ConsumerState<BasePointScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AlfredAppBar(),
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
                    // Bottom Button with margin
                    Padding(
                      padding: const EdgeInsets.only(bottom: 36, left: 16, right: 16),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: BottomActionButton(
                            text: "I am at the Base Point",
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => SaveStartingPointDialog(),
                              );
                            },
                            isActive: true, // You can add logic here if needed
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


