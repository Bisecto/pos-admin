import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class OrdersLineChart extends StatelessWidget {
  final List<int> orderCounts; // List of order counts for each day (7 days)

  OrdersLineChart({required this.orderCounts});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            bottomTitles: SideTitles(
              showTitles: true,
              getTitles: (value) {
                const daysOfWeek = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ];
                return daysOfWeek[value.toInt()];
              },
              interval: 1,
            ),
            leftTitles: SideTitles(
              showTitles: true,
              getTitles: (value) {
                return value.toInt().toString(); // Y-axis values as integers
              },
              interval: 500, // Adjust interval based on your data
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black26),
          ),
          minX: 0,
          maxX: 6,
          // 7 days (0-6)
          minY: 0,
          maxY: orderCounts
              .reduce((curr, next) => curr > next ? curr : next)
              .toDouble(),
          // Max order count as Y-axis max
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                  7,
                  (index) =>
                      FlSpot(index.toDouble(), orderCounts[index].toDouble())),
              isCurved: true,
              dotData: FlDotData(show: false),
              colors: [Colors.green],
              barWidth: 3,
              belowBarData: BarAreaData(
                  show: true, colors: [Colors.green.withOpacity(0.3)]),
            ),
          ],
        ),
      ),
    );
  }
}
