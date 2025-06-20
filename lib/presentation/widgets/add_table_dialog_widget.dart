
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alfred/view_models/table_view_model.dart';
import '../../core/toast_utils.dart';

class AddTableDialogWidget extends StatelessWidget {
  const AddTableDialogWidget({super.key});

  static void showAddTableDialog({
    required BuildContext context,
    required TextEditingController tableNumberController,
    required WidgetRef ref,
    // Add the callback function as a required parameter.
    required Function(int) onTableAdded,
    required List<int> tablesFromROS,

  }) {
    tableNumberController.clear();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (KeyEvent event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace) {
              if (tableNumberController.text.isNotEmpty) {
                tableNumberController.text = tableNumberController.text
                    .substring(0, tableNumberController.text.length - 1);
              }
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth > 642.w ? 642.w : constraints.maxWidth * 0.9,
                  height: constraints.maxHeight > 300.h ? 300.h : constraints.maxHeight * 0.9,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Left Column
                      Flexible(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enter Table number',
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.33,
                                ),
                                semanticsLabel: 'Enter Table number',
                              ),
                              SizedBox(height: 20.h),
                              SizedBox(
                                height: 48.h,
                                child: TextField(
                                  controller: tableNumberController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        width: 1.0.w,
                                        color: const Color(0xFF757575),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        width: 1.0.w,
                                        color: const Color(0xFF757575),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(
                                        width: 1.0.w,
                                        color: const Color(0xFF757575),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 10.h,
                                    ),
                                  ),
                                  style: GoogleFonts.roboto(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Divider(
                                color: Colors.grey[300],
                                thickness: 1.w,
                              ),
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          width: 1.0.w,
                                          color: const Color(0xFF757575),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 25.w,
                                          vertical: 20.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        'Cancel',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          color: Colors.black,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w500,
                                          height: 1,
                                          letterSpacing: 0.10.w,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (tableNumberController.text.isEmpty) {
                                          showErrorToast(
                                            context: context,
                                            description: "Please enter a table number",
                                          );
                                          return;
                                        }
                                        final tableNumber =
                                        int.tryParse(tableNumberController.text);
                                        if (tableNumber == null || tableNumber <= 0) {
                                          showErrorToast(
                                            context: context,
                                            description:
                                            "Please enter a valid positive number",
                                          );
                                          return;
                                        }
                                        // Read the list of marked tables (List<int>) from the new provider.
                                        final currentTables = ref.read(tableVMProvider);
                                        // Update the check to use .contains() on a List<int>.
                                        if (currentTables.contains(tableNumber)) {
                                          showErrorToast(
                                            context: context,
                                            description: "Table $tableNumber is already marked",
                                          );
                                          return;
                                        }
                                        // Call the callback to pass the new number back to the TrainingScreen.
                                        onTableAdded(tableNumber);

                                        // ref.read(tableVMProvider.notifier).addCustomTable(tableNumber);

                                        Navigator.of(dialogContext).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 25.w,
                                          vertical: 20.h,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                      ),
                                      child: Text(
                                        'Add Table',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          height: 1,
                                          letterSpacing: 0.10.w,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right Column (Number Pad)
                      Flexible(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildNumberButton(tableNumberController, 1),
                                  _buildNumberButton(tableNumberController, 2),
                                  _buildNumberButton(tableNumberController, 3),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildNumberButton(tableNumberController, 4),
                                  _buildNumberButton(tableNumberController, 5),
                                  _buildNumberButton(tableNumberController, 6),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildNumberButton(tableNumberController, 7),
                                  _buildNumberButton(tableNumberController, 8),
                                  _buildNumberButton(tableNumberController, 9),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildNumberButton(tableNumberController, 0),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  static Widget _buildNumberButton(
      TextEditingController controller, int number) {
    return SizedBox(
      width: 48.w,
      height: 48.h,
      child: ElevatedButton(
        onPressed: () {
          // Prevent leading zeros and limit length if desired
          if (controller.text.length < 3) { // Example limit
            controller.text += number.toString();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey[300]!),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          number.toString(),
          style: GoogleFonts.nunito(
            fontSize: 18.sp,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          semanticsLabel: 'Number $number',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}