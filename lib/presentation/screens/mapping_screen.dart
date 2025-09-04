import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class MappingScreen extends ConsumerWidget {

  const MappingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final topics = ref.watch(robotTopicsViewModelProvider);
    // final odom = topics.odom;
    // final mapGrid = topics.map;
    // final selectedTable = ref.watch(selectedTableProvider);
    // return Scaffold(
    //   appBar: AppBar(title: const Text('Map & Table Selection')),
    //   body: Row(
    //     children: [
    //       // Left side: Display occupancy grid with odom overlay and waiter instruction.
    //       Expanded(
    //         flex: 2,
    //         child: Stack(
    //           children: [
    //             mapGrid != null
    //                 ? Center(child: OccupancyGridWidget(occupancyGrid: mapGrid))
    //                 : const Center(child: CircularProgressIndicator()),
    //             Positioned(
    //               top: 10,
    //               left: 10,
    //               child: odom != null
    //                   ? Container(
    //                 padding: const EdgeInsets.all(8),
    //                 color: Colors.white.withOpacity(0.8),
    //                 child: Text(
    //                   I18n.en.mapOdomData(
    //                     x: odom.x.toStringAsFixed(2),
    //                     y: odom.y.toStringAsFixed(2),
    //                     theta: odom.orientation.toStringAsFixed(2),
    //                   ),
    //                   style: const TextStyle(fontSize: 14),
    //                 ),
    //               )
    //                   : const SizedBox.shrink(),
    //             ),
    //             Positioned(
    //               bottom: 10,
    //               left: 10,
    //               child: Column(
    //                 children: [
    //                   Image.asset('assets/images/waiter.png', height: 100),
    //                   const SizedBox(height: 8),
    //                   Text(I18n.en.waiterInstruction),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //       // Right side: Grid of table buttons and Save/Next buttons.
    //       Expanded(
    //         flex: 3,
    //         child: Column(
    //           children: [
    //             Expanded(
    //               child: GridView.builder(
    //                 padding: const EdgeInsets.all(8),
    //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //                   crossAxisCount: 3,
    //                   childAspectRatio: 2,
    //                   crossAxisSpacing: 8,
    //                   mainAxisSpacing: 8,
    //                 ),
    //                 itemCount: 20,
    //                 itemBuilder: (context, index) {
    //                   final tableNum = index + 1;
    //                   return TableButton(
    //                     tableNumber: tableNum,
    //                     isSelected: selectedTable == tableNum,
    //                     onTap: () => ref.read(selectedTableProvider.notifier).state = tableNum,
    //                   );
    //                 },
    //               ),
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.end,
    //                 children: [
    //                   ElevatedButton(
    //                     onPressed: selectedTable != null
    //                         ? () async {
    //                       final odomData = await ref.read(rosConnectionProvider).getLatestOdom();
    //                       if (odomData != null) {
    //                         await ref.read(localDatabaseProvider).insertTableData(odomData, selectedTable!);
    //                         ScaffoldMessenger.of(context).showSnackBar(
    //                           SnackBar(content: Text('Data saved for Table $selectedTable')),
    //                         );
    //                       }
    //                     }
    //                         : null,
    //                     child: const Text('Save'),
    //                   ),
    //                   const SizedBox(width: 16),
    //                   ElevatedButton(
    //                     onPressed: selectedTable != null ? () => context.go('/storedTables') : null,
    //                     child: const Text('Next'),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    return Container();
  }

}