import 'package:flutter/material.dart';
import 'package:norimoto/data/repositories/vehicle_repository.dart';
import 'package:norimoto/domain/models/vehicle.dart';
import 'package:norimoto/presentation/screens/vehicle_details_screen.dart';
import 'package:norimoto/presentation/theme/app_theme.dart';
import 'package:intl/intl.dart';

class VehicleList extends StatefulWidget {
  const VehicleList({super.key});

  @override
  State<VehicleList> createState() => _VehicleListState();
}

class _VehicleListState extends State<VehicleList> {
  @override
  void initState() {
    super.initState();
    VehicleRepository.getAllVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Vehicle>>(
      stream: VehicleRepository.vehiclesStream,
      initialData: const [],
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppTheme.primary,
                ),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        final vehicles = snapshot.data ?? [];

        if (vehicles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  size: 64,
                  color: AppTheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No vehicles added yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first vehicle',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.white.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicles[index];
            return _VehicleCard(vehicle: vehicle);
          },
        );
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Vehicle Icon with Background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      vehicle.type == VehicleType.company
                          ? Icons.business
                          : Icons.directions_car,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Vehicle Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${vehicle.make} ${vehicle.model}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vehicle.licensePlate,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Year Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vehicle.year.toString(),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      'Transmission',
                      vehicle.transmission.name.toUpperCase(),
                      Icons.settings,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: colorScheme.outlineVariant.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      'Fuel Type',
                      vehicle.fuelType.name.toUpperCase(),
                      Icons.local_gas_station,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: colorScheme.outlineVariant.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      context,
                      'Price',
                      NumberFormat.compactCurrency(symbol: '\$')
                          .format(vehicle.purchasePrice),
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
            ),

            // Company Info Section (if applicable)
            if (vehicle.type == VehicleType.company &&
                vehicle.companyName != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer.withOpacity(0.3),
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.business,
                      size: 18,
                      color: colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      vehicle.companyName!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (vehicle.employeeId != null) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID: ${vehicle.employeeId}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onTertiaryContainer,
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
