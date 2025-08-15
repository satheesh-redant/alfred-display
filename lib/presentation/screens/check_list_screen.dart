import 'package:alfred/src/core/configs/alfred_constants.dart';
import 'package:alfred/presentation/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/checklist_item.dart';
import '../widgets/button_widget.dart';

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  final List<ChecklistItem> _checklistItems = [
    const ChecklistItem(
      title: "Take Alfred to the Start point",
      image: "assets/images/checklist_1.png",
    ),
    const ChecklistItem(
      title: "Remove all wires or cables from the path that might obstruct Alfred's movement",
      image: "assets/images/checklist_1.png",
    ),
    const ChecklistItem(
      title: "Ensure the floor is clear of obstacles",
      image: "assets/images/checklist_1.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final allTasksCompleted = _checklistItems.every((item) => item.completed);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWidget(),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Title
                  Text(
                    "Let's Setup Alfred",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                    fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                SizedBox(height: 24.h),
                // Subtitle
                  Text(
                    "Please complete the checks before marking the tables with Alfred",
                    style: GoogleFonts.inter(
                      color: Colors.black,
                    fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          // Checklist Items Area
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: _buildChecklistArea(),
            ),
          ),
          // Continue Button
            Padding(
            padding: EdgeInsets.symmetric(horizontal: 300.w, vertical: 36.h),
        child: ButtonWidget(
          text: "Continue",
              onPressed: allTasksCompleted
              ? () {
                  print('All tasks completed. Proceeding to the next screen.');
                  context.go(AlfredConstants.routeBasePointMarkingScreen);
                }
              : null,
              isActive: allTasksCompleted,
            ),
        ),
        ],
      ),
    );
  }

  Widget _buildChecklistArea() {
    final checklistCards = _checklistItems.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return _buildChecklistCard(
        title: item.title,
        value: item.completed,
        image: item.image,
        onChanged: (val) {
          if (val == null) return;
          setState(() {
            _checklistItems[index] = item.copyWith(completed: val);
          });
          print('Task ${index + 1} - ${item.title}: ${val ? "Completed" : "Not Completed"}');
        },
        isBlueBorder: item.isBlueBorder,
      );
    }).toList();

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: checklistCards,
      ),
    );
  }

  Widget _buildChecklistCard({
    required String title,
    required bool value,
    required String image,
    required Function(bool?) onChanged,
    bool isBlueBorder = false,
  }) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        width: 1.sw, // Full screen width
        margin: EdgeInsets.symmetric(vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.w,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2F000000),
              blurRadius: 3,
              offset: Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 8.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 28.h,
                        width: 28.w,
                        child: Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            value: value,
                            onChanged: onChanged,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                            activeColor: Colors.black,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.roboto(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                child: Image.asset(
                  image,
                  height: 70.h,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 70.h,
                      width: 70.w,
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, size: 40.sp, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}