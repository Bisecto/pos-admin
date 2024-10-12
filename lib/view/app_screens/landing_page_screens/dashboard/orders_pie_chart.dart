import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OrdersPieChart extends StatelessWidget {
  final int completedOrders;
  final int pendingOrders;
  final int canceledOrders;

  OrdersPieChart({
    required this.completedOrders,
    required this.pendingOrders,
    required this.canceledOrders,
  });

  @override
  Widget build(BuildContext context) {
    int totalOrders = completedOrders + pendingOrders + canceledOrders;

    return Container(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: completedOrders.toDouble(),
              color: Colors.green,
              title: totalOrders > 0 ? '${((completedOrders / totalOrders) * 100).toStringAsFixed(1)}%' : '0%',
              radius: 50,
              titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: pendingOrders.toDouble(),
              color: Colors.orange,
              title: totalOrders > 0 ? '${((pendingOrders / totalOrders) * 100).toStringAsFixed(1)}%' : '0%',
              radius: 50,
              titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: canceledOrders.toDouble(),
              color: Colors.red,
              title: totalOrders > 0 ? '${((canceledOrders / totalOrders) * 100).toStringAsFixed(1)}%' : '0%',
              radius: 50,
              titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }
}
