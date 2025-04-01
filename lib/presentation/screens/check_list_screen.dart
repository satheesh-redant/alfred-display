import 'package:alfred/config/alfred_constants.dart';
import 'package:alfred/presentation/widgets/alfred_appbar.dart';
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Let's Setup Alfred",
              style: GoogleFonts.inter(textStyle: Theme.of(context).textTheme.titleMedium, fontSize: 24, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10),
            Text(
              "Please complete the checks before marking the tables with Alfred",
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 20),

            // Task Card (Blue Outline)
            _buildChecklistCard(
              title: "Take Alfred to the Start point",
              value: _task1Completed,
              image: "assets/images/checklist_1.png",
              onChanged: (val) {
                setState(() {
                  _task1Completed = val;
                });
              },
              isBlueBorder: true,
            ),

            // Task Card (White Background)
            _buildChecklistCard(
              title: "Remove all wires or cables from the path",
              value: _task2Completed,
              image: "assets/images/checklist_1.png",
              onChanged: (val) {
                setState(() {
                  _task2Completed = val;
                });
              },
            ),

            // Task Card (White Background)
            _buildChecklistCard(
              title: "Take Alfred to the Start point",
              value: _task3Completed,
              image: "assets/images/checklist_1.png",
              onChanged: (val) {
                setState(() {
                  _task3Completed = val;
                });
              },
            ),

            Spacer(),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: (_task1Completed && _task2Completed && _task3Completed)
                    ? () {
                        context.go(AlfredConstants.routeBasePointScreen);
                      }
                    : null, // Disabled if tasks are not completed
                child: Text(
                  "Continue",
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Checklist Item
  Widget _buildChecklistCard({
    required String title,
    required bool value,
    required String image,
    required Function(bool) onChanged,
    bool isBlueBorder = false,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isBlueBorder ? Colors.white : Colors.transparent, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, top: 30, bottom: 30),
            child: Row(
              children: [
                SizedBox(
                  height: 28,
                  width: 28,
                  child: Checkbox(
                    value: value,
                    onChanged: (val) => onChanged(val!),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                    activeColor: Colors.black,
                  ),
                ),
                SizedBox(width: 10),
                Text(title, style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 20),
            child: Image.asset(image, height: 95),
          )
        ],
      ),
    );
  }
}
