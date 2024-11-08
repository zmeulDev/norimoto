import 'package:flutter/material.dart';
import 'package:norimoto/domain/models/service_record.dart';
import 'package:norimoto/domain/models/fuel_record.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class CostStatistics extends StatelessWidget {
  final String vehicleId;
  final List<ServiceRecord> serviceRecords;
  final List<FuelRecord> fuelRecords;

  const CostStatistics({
    super.key,
    required this.vehicleId,
    required this.serviceRecords,
    required this.fuelRecords,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('CostStatistics build');
    debugPrint('Service Records: ${serviceRecords.length}');
    debugPrint('Fuel Records: ${fuelRecords.length}');

    if (serviceRecords.isEmpty && fuelRecords.isEmpty) {
      debugPrint('No records found for vehicle: $vehicleId');
      return const Center(
        child: Text('No cost data to analyze'),
      );
    }

    final totalServiceCost = serviceRecords.fold<double>(
      0.0,
      (sum, record) => sum + record.cost,
    );

    final totalFuelCost = fuelRecords.fold<double>(
      0.0,
      (sum, record) => sum + record.cost,
    );

    debugPrint('Total Service Cost: $totalServiceCost');
    debugPrint('Total Fuel Cost: $totalFuelCost');

    final totalCost = totalServiceCost + totalFuelCost;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTotalCostCard(
          context,
          totalCost,
          totalServiceCost,
          totalFuelCost,
        ),
        const SizedBox(height: 16),
        _buildMonthlyChart(context),
        const SizedBox(height: 16),
        _buildCostBreakdownChart(context),
        const SizedBox(height: 16),
        _buildCostHistoryList(context),
      ],
    );
  }

  Widget _buildTotalCostCard(
    BuildContext context,
    double totalCost,
    double serviceCost,
    double fuelCost,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Costs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildCostRow(
              context,
              'Total Expenses',
              currencyFormat.format(totalCost),
              color: Theme.of(context).colorScheme.primary,
            ),
            _buildCostRow(
              context,
              'Service Costs',
              currencyFormat.format(serviceCost),
            ),
            _buildCostRow(
              context,
              'Fuel Costs',
              currencyFormat.format(fuelCost),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(BuildContext context, String label, String value,
      {Color? color}) {
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
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context) {
    final monthlyCosts = _calculateMonthlyCosts();
    if (monthlyCosts.isEmpty) return const SizedBox.shrink();

    final spots = monthlyCosts.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value,
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Expenses',
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
                            '\$${value.toInt()}',
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
                              DateFormat.MMM().format(date),
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
                      spots: spots,
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

  Widget _buildCostBreakdownChart(BuildContext context) {
    final sections = _calculateCostBreakdown();
    if (sections.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: sections.map((section) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: section.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(section.title),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostHistoryList(BuildContext context) {
    final allCosts = [
      ...serviceRecords.map((record) => _CostRecord(
            date: record.date,
            description: record.title,
            cost: record.cost,
            type: 'Service',
          )),
      ...fuelRecords.map((record) => _CostRecord(
            date: record.date,
            description: 'Fuel',
            cost: record.cost,
            type: 'Fuel',
          )),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...allCosts.map((record) => _buildCostHistoryItem(context, record)),
          ],
        ),
      ),
    );
  }

  Widget _buildCostHistoryItem(BuildContext context, _CostRecord record) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  DateFormat.yMMMd().format(record.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(symbol: '\$').format(record.cost),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                record.type,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<DateTime, double> _calculateMonthlyCosts() {
    final monthlyCosts = <DateTime, double>{};

    void addCost(DateTime date, double cost) {
      final monthStart = DateTime(date.year, date.month, 1);
      monthlyCosts[monthStart] = (monthlyCosts[monthStart] ?? 0) + cost;
    }

    for (final record in serviceRecords) {
      addCost(record.date, record.cost);
    }

    for (final record in fuelRecords) {
      addCost(record.date, record.cost);
    }

    return Map.fromEntries(
      monthlyCosts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  List<PieChartSectionData> _calculateCostBreakdown() {
    final costs = <String, double>{};

    // Initialize 'Fuel' category
    costs['Fuel'] =
        fuelRecords.fold<double>(0.0, (sum, record) => sum + record.cost);

    // Group service costs by type
    for (final record in serviceRecords) {
      final type = record.type.toString().split('.').last.toUpperCase();
      costs[type] = (costs[type] ?? 0.0) + record.cost;
    }

    // Remove categories with zero cost
    costs.removeWhere((key, value) => value == 0);

    if (costs.isEmpty) return [];

    final totalCost = costs.values.fold<double>(0.0, (sum, cost) => sum + cost);
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
    ];

    return costs.entries.map((entry) {
      final index = costs.keys.toList().indexOf(entry.key);
      final percentage = (entry.value / totalCost * 100);
      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value,
        title: percentage < 5 ? '' : '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}

class _CostRecord {
  final DateTime date;
  final String description;
  final double cost;
  final String type;

  _CostRecord({
    required this.date,
    required this.description,
    required this.cost,
    required this.type,
  });
}
