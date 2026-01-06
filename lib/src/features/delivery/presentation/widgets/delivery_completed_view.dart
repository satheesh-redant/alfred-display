import 'package:alfred/src/shared/states/system_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/delivery_providers.dart';
import '../../state/delivery_state.dart';

class DeliveryCompletedView extends ConsumerStatefulWidget {
  final SystemState systemState;
  final DeliveryState deliveryState;

  const DeliveryCompletedView({
    super.key,
    required this.systemState,
    required this.deliveryState,
  });

  @override
  ConsumerState<DeliveryCompletedView> createState() => _DeliveryCompletedViewState();
}

class _DeliveryCompletedViewState extends ConsumerState<DeliveryCompletedView> {
  final ScrollController _gridScrollController = ScrollController();

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildSuccessMessage(),
        _buildNextDestinationCard(),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    return Expanded(
      flex: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Destination Reached",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 32.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            widget.deliveryState.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 18.sp, color: Colors.black54),
          ),
          SizedBox(height: 64.h),
          Flexible(
            child: Image.asset(
              "assets/images/alfred_ready.png",
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextDestinationCard() {
    final deliveryVM = ref.read(deliveryViewModelProvider.notifier);

    return Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.only(top: 50.h, right: 40.w),
        child: Card(
          elevation: 6,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Next Destination",
                  style: GoogleFonts.nunito(fontSize: 16.sp, color: Colors.grey),
                ),
                SizedBox(height: 30.h),
                Expanded(child: _buildDestinationGrid(deliveryVM)),
                SizedBox(height: 20.h),
                _buildNavigateButton(deliveryVM),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationGrid(dynamic deliveryVM) {
    return GridView.builder(
      controller: _gridScrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 49.w,
        mainAxisSpacing: 26.h,
      ),
      itemCount: widget.deliveryState.availableTables.length,
      itemBuilder: (context, index) {
        final tableId = widget.deliveryState.availableTables[index];
        final isSelected = tableId == widget.deliveryState.selectedTable;

        return ElevatedButton(
          onPressed: () => deliveryVM.selectTable(isSelected ? null : tableId),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
          ),
          child: Text(
            tableId == 0 ? 'Base' : 'Table $tableId',
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigateButton(dynamic deliveryVM) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: widget.deliveryState.selectedTable != null
            ? deliveryVM.goToTable
            : null,
        child: Text(
          widget.deliveryState.selectedTable == 0
              ? "Return to Base"
              : "Go to Table ${widget.deliveryState.selectedTable ?? ''}",
          style: GoogleFonts.nunito(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
