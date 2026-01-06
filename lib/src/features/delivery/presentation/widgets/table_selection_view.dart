import 'package:alfred/src/features/delivery/presentation/widgets/sidebar_widget.dart';
import 'package:alfred/src/features/delivery/state/delivery_state.dart';
import 'package:alfred/src/shared/states/system_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/delivery_providers.dart';

class TableSelectionView extends ConsumerStatefulWidget {
  final SystemState systemState;
  final DeliveryState deliveryState;

  const TableSelectionView({
    super.key,
    required this.systemState,
    required this.deliveryState,
  });

  @override
  ConsumerState<TableSelectionView> createState() => _TableSelectionViewState();
}

class _TableSelectionViewState extends ConsumerState<TableSelectionView> {
  final ScrollController _gridScrollController = ScrollController();

  @override
  void dispose() {
    _gridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryVM = ref.read(deliveryViewModelProvider.notifier);

    return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SidebarWidget(systemState: widget.systemState),
          _buildAlfredBaseSection(),
          SizedBox(width: 20.w),
          _buildTableSelectionCard(deliveryVM),
        ],
      ),
    );
  }

  Widget _buildAlfredBaseSection() {
    return Expanded(
      flex: 2,
      child: Stack(
        children: [
          Positioned(
            left: 125.w,
            top: 50.h,
            child: Text(
              "Alfred at Base",
              style: GoogleFonts.nunito(
                fontSize: 20.sp,
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            left: 60.w,
            right: 140.w,
            top: 140.h,
            bottom: 0.h,
            child: Image.asset(
              "assets/images/alfred_base_point.png",
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSelectionCard(dynamic deliveryVM) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: EdgeInsets.only(top: 50.h, right: 40.w),
        child: Card(
          elevation: 6,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Tables",
                  style: GoogleFonts.nunito(fontSize: 16.sp, color: Colors.grey),
                ),
                SizedBox(height: 30.h),
                Expanded(
                  child: widget.deliveryState.availableTables.isEmpty
                      ? _buildEmptyState()
                      : _buildTableGrid(deliveryVM),
                ),
                SizedBox(height: 20.h),
                _buildGoButton(deliveryVM),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "No tables marked yet\nPlease mark tables in Training Mode first",
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(fontSize: 16.sp, color: Colors.grey),
      ),
    );
  }

  Widget _buildTableGrid(dynamic deliveryVM) {
    return Scrollbar(
      controller: _gridScrollController,
      thumbVisibility: true,
      child: GridView.builder(
        controller: _gridScrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 49.w,
          mainAxisSpacing: 26.h,
          childAspectRatio: (138.w / 60.h),
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
              'Table $tableId',
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoButton(dynamic deliveryVM) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: widget.deliveryState.selectedTable != null &&
            !widget.deliveryState.isLoading
            ? deliveryVM.goToTable
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.deliveryState.selectedTable != null
              ? Colors.blue
              : Colors.grey[400],
        ),
        child: widget.deliveryState.isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text("Go to Table", style: GoogleFonts.nunito(fontSize: 16.sp)),
      ),
    );
  }
}
