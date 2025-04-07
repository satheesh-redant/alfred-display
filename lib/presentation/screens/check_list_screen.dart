

import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/presentation/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  bool _task1Completed = false;
  bool _task2Completed = false;
  bool _task3Completed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AlfredAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// **Header Section**
            Padding(
              padding: const EdgeInsets.only(
                top: 40.0,
                left: 61.0,
                right: 8.0,
                bottom: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Let's Setup Alfred",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 24.2 / 24,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    "Please complete the checks before marking the tables with Alfred",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      height: 24.2 / 20,
                    ),
                  ),
                ],
              ),
            ),

            /// **Checklist Items**
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                children: [
                  _buildChecklistCard(
                    title: "Take Alfred to the Start point",
                    value: _task1Completed,
                    image: "assets/images/checklist_1.png",
                    onChanged: (val) => setState(() => _task1Completed = val!),
                    isBlueBorder: true,
                  ),
                  _buildChecklistCard(
                    title: "Remove all wires or cables from the path",
                    value: _task2Completed,
                    image: "assets/images/checklist_1.png",
                    onChanged: (val) => setState(() => _task2Completed = val!),
                  ),
                  _buildChecklistCard(
                    title: "Ensure the floor is clear of obstacles",
                    value: _task3Completed,
                    image: "assets/images/checklist_1.png",
                    onChanged: (val) => setState(() => _task3Completed = val!),
                  ),
                ],
              ),
            ),

            /// **Spacer before button**
            const SizedBox(height: 10),
          ],
        ),
      ),

      /// **Bottom Continue Button**
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 300.0, right: 300.0, bottom: 36.0),
        child: SizedBox(
          width: 697,
          height: 80,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: (_task1Completed && _task2Completed && _task3Completed)
                ? () => context.go(AlfredConstants.routeBasePointScreen)
                : null,
            child: Text(
              "Continue",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// **Checklist Card Builder**
  Widget _buildChecklistCard({
    required String title,
    required bool value,
    required String image,
    required Function(bool?) onChanged,
    bool isBlueBorder = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBlueBorder ? Colors.white : Colors.transparent,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        child: Row(
          children: [
            /// **Checkbox & Title**
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 42),
                child: Row(
                  children: [
                    SizedBox(
                      height: 28,
                      width: 28,
                      child: Checkbox(
                        value: value,
                        onChanged: onChanged,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                        activeColor: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400,color: Colors.black ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// **Checklist Image**
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Image.asset(
                image,
                height: 95,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

