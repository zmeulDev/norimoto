import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/data/repositories/service_repository.dart';
import 'package:norimoto/data/repositories/fuel_repository.dart';
import 'package:norimoto/data/repositories/vehicle_repository.dart';
import 'package:norimoto/domain/models/service_record.dart';
import 'package:norimoto/domain/models/fuel_record.dart';
import 'package:norimoto/domain/models/vehicle.dart';
import 'package:norimoto/domain/models/service_type.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' show max;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    ServiceRepository.getAllServices();
    FuelRepository.getAllFuelRecords();
    VehicleRepository.getAllVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(
        title: 'Statistics',
      ),
      body: StreamBuilder<List<Vehicle>>(
        stream: VehicleRepository.vehiclesStream,
        initialData: const [],
        builder: (context, vehicleSnapshot) {
          return StreamBuilder<List<ServiceRecord>>(
            stream: ServiceRepository.servicesStream,
            initialData: const [],
            builder: (context, serviceSnapshot) {
              return StreamBuilder<List<FuelRecord>>(
                stream: FuelRepository.fuelRecordsStream,
                initialData: const [],
                builder: (context, fuelSnapshot) {
                  if (vehicleSnapshot.hasError ||
                      serviceSnapshot.hasError ||
                      fuelSnapshot.hasError) {
                    return Center(
                      child: Text(
                          'Error: ${vehicleSnapshot.error ?? serviceSnapshot.error ?? fuelSnapshot.error}'),
                    );
                  }

                  final vehicles = vehicleSnapshot.data ?? [];
                  final services = serviceSnapshot.data ?? [];
                  final fuels = fuelSnapshot.data ?? [];

                  if (vehicles.isEmpty) {
                    return const Center(
                      child: Text('No vehicles to analyze'),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildOverallStats(context, vehicles, services, fuels),
                      const SizedBox(height: 16),
                      _buildMonthlyExpensesChart(context, services, fuels),
                      const SizedBox(height: 16),
                      _buildVehicleCostsComparison(
                          context, vehicles, services, fuels),
                      const SizedBox(height: 16),
                      _buildServiceTypeBreakdown(context, services),
                      const SizedBox(height: 16),
                      _buildFuelConsumptionStats(context, vehicles, fuels),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context, List<Vehicle> vehicles,
      List<ServiceRecord> services, List<FuelRecord> fuels) {
    final totalServiceCost =
        services.fold<double>(0, (sum, service) => sum + service.cost);
    final totalFuelCost = fuels.fold<double>(0, (sum, fuel) => sum + fuel.cost);
    final totalCost = totalServiceCost + totalFuelCost;

    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(),
            _buildStatRow(
              context,
              'Total Vehicles',
              vehicles.length.toString(),
              Icons.directions_car,
            ),
            _buildStatRow(
              context,
              'Total Services',
              services.length.toString(),
              Icons.build,
            ),
            _buildStatRow(
              context,
              'Total Fuel Records',
              fuels.length.toString(),
              Icons.local_gas_station,
            ),
            _buildStatRow(
              context,
              'Total Expenses',
              currencyFormat.format(totalCost),
              Icons.attach_money,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyExpensesChart(BuildContext context,
      List<ServiceRecord> services, List<FuelRecord> fuels) {
    final monthlyCosts = <DateTime, double>{};

    // Combine service and fuel costs by month
    for (final service in services) {
      final month = DateTime(service.date.year, service.date.month);
      monthlyCosts[month] = (monthlyCosts[month] ?? 0) + service.cost;
    }

    for (final fuel in fuels) {
      final month = DateTime(fuel.date.year, fuel.date.month);
      monthlyCosts[month] = (monthlyCosts[month] ?? 0) + fuel.cost;
    }

    final sortedMonths = monthlyCosts.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    if (sortedMonths.isEmpty) return const SizedBox.shrink();

    final spots = sortedMonths.map((month) {
      return FlSpot(
        month.millisecondsSinceEpoch.toDouble(),
        monthlyCosts[month]!,
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

  Widget _buildVehicleCostsComparison(
      BuildContext context,
      List<Vehicle> vehicles,
      List<ServiceRecord> services,
      List<FuelRecord> fuels) {
    final vehicleCosts = <String, double>{};

    // Calculate total costs per vehicle
    for (final vehicle in vehicles) {
      final vehicleServices =
          services.where((s) => s.vehicleId == vehicle.id).toList();
      final vehicleFuels =
          fuels.where((f) => f.vehicleId == vehicle.id).toList();

      final serviceCost =
          vehicleServices.fold<double>(0, (sum, s) => sum + s.cost);
      final fuelCost = vehicleFuels.fold<double>(0, (sum, f) => sum + f.cost);

      vehicleCosts['${vehicle.year} ${vehicle.make} ${vehicle.model}'] =
          serviceCost + fuelCost;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost by Vehicle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...vehicleCosts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(
                  value: entry.value /
                      (vehicleCosts.values
                          .reduce((max, value) => value > max ? value : max)),
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  color: Theme.of(context).colorScheme.primary,
                  minHeight: 20,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeBreakdown(
      BuildContext context, List<ServiceRecord> services) {
    final typeBreakdown = <String, double>{};
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    for (final service in services) {
      final type = service.type.displayName;
      typeBreakdown[type] = (typeBreakdown[type] ?? 0) + service.cost;
    }

    final totalCost =
        typeBreakdown.values.fold<double>(0, (sum, cost) => sum + cost);
    final sortedEntries = typeBreakdown.entries.toList()
      ..sort(
          (a, b) => b.value.compareTo(a.value)); // Sort by cost, highest first

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Type Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...sortedEntries.map((entry) {
              final index = sortedEntries.indexOf(entry);
              final percentage = (entry.value / totalCost * 100);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          ServiceType.values
                              .firstWhere((t) => t.displayName == entry.key)
                              .icon,
                          color: colors[index % colors.length],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          currencyFormat.format(entry.value),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value / typeBreakdown.values.reduce(max),
                        backgroundColor:
                            colors[index % colors.length].withOpacity(0.1),
                        color: colors[index % colors.length],
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelConsumptionStats(
      BuildContext context, List<Vehicle> vehicles, List<FuelRecord> fuels) {
    final vehicleConsumption = <String, double>{};

    for (final vehicle in vehicles) {
      final vehicleFuels =
          fuels.where((f) => f.vehicleId == vehicle.id).toList();
      if (vehicleFuels.length >= 2) {
        vehicleFuels.sort((a, b) => a.date.compareTo(b.date));
        double totalConsumption = 0;
        int count = 0;

        for (int i = 1; i < vehicleFuels.length; i++) {
          final current = vehicleFuels[i];
          final previous = vehicleFuels[i - 1];
          final distance = current.odometer - previous.odometer;
          if (distance > 0) {
            totalConsumption += (current.liters * 100) / distance;
            count++;
          }
        }

        if (count > 0) {
          vehicleConsumption[
                  '${vehicle.year} ${vehicle.make} ${vehicle.model}'] =
              totalConsumption / count;
        }
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Average Fuel Consumption',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...vehicleConsumption.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.value.toStringAsFixed(2)} L/100km',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, String label, String value, IconData icon,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
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
}
