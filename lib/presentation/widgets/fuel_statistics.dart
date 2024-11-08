import 'package:flutter/material.dart';
import 'package:norimoto/data/repositories/fuel_repository.dart';
import 'package:norimoto/domain/models/fuel_record.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class FuelStatistics extends StatelessWidget {
  final String vehicleId;
  final List<FuelRecord> records;

  const FuelStatistics({
    super.key,
    required this.vehicleId,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const Center(
        child: Text('No fuel records to analyze'),
      );
    }

    return FutureBuilder<Map<String, double>>(
      future: FuelRepository.getVehicleStatistics(vehicleId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        final currencyFormat = NumberFormat.currency(symbol: '\$');
        final numberFormat = NumberFormat('#,##0.00');

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCard(
              context,
              stats,
              currencyFormat,
              numberFormat,
            ),
            const SizedBox(height: 16),
            _buildConsumptionChart(context),
            const SizedBox(height: 16),
            _buildCostChart(context),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    Map<String, double> stats,
    NumberFormat currencyFormat,
    NumberFormat numberFormat,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildStatRow(
              context,
              'Total Cost',
              currencyFormat.format(stats['totalCost']!),
            ),
            _buildStatRow(
              context,
              'Total Fuel',
              '${numberFormat.format(stats['totalLiters']!)} L',
            ),
            _buildStatRow(
              context,
              'Average Cost/L',
              currencyFormat.format(stats['averageCost']!),
            ),
            _buildStatRow(
              context,
              'Average Consumption',
              '${numberFormat.format(stats['averageConsumption']!)} L/100km',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionChart(BuildContext context) {
    final sortedRecords = List<FuelRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedRecords.length < 2) {
      return const SizedBox.shrink();
    }

    final consumptionSpots = <FlSpot>[];
    for (int i = 1; i < sortedRecords.length; i++) {
      final current = sortedRecords[i];
      final previous = sortedRecords[i - 1];
      final distance = current.odometer - previous.odometer;
      if (distance > 0) {
        final consumption = (current.liters * 100) / distance;
        consumptionSpots.add(FlSpot(
          current.date.millisecondsSinceEpoch.toDouble(),
          consumption,
        ));
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fuel Consumption',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat.MMMd().format(date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: consumptionSpots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostChart(BuildContext context) {
    final sortedRecords = List<FuelRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sortedRecords.isEmpty) {
      return const SizedBox.shrink();
    }

    final costSpots = sortedRecords.map((record) {
      return FlSpot(
        record.date.millisecondsSinceEpoch.toDouble(),
        record.pricePerLiter,
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fuel Price Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat.MMMd().format(date),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: costSpots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.secondary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
