import 'package:flutter/material.dart';
import 'package:norimoto/domain/models/service_record.dart';
import 'package:norimoto/domain/models/vehicle.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:norimoto/presentation/screens/edit_service_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceRecord service;
  final Vehicle vehicle;

  const ServiceDetailsScreen({
    super.key,
    required this.service,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: service.title,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditServiceScreen(
                    service: service,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context,
                    'Vehicle',
                    '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                    Icons.directions_car,
                  ),
                  _buildInfoRow(
                    context,
                    'Type',
                    service.type.displayName,
                    service.type.icon,
                  ),
                  _buildInfoRow(
                    context,
                    'Date',
                    DateFormat.yMMMd().format(service.date),
                    Icons.calendar_today,
                  ),
                  _buildInfoRow(
                    context,
                    'Cost',
                    NumberFormat.currency(symbol: '\$').format(service.cost),
                    Icons.attach_money,
                  ),
                  _buildInfoRow(
                    context,
                    'Mileage',
                    '${NumberFormat('#,###').format(service.mileage)} km',
                    Icons.speed,
                  ),
                  if (service.serviceProvider.isNotEmpty)
                    _buildInfoRow(
                      context,
                      'Provider',
                      service.serviceProvider,
                      Icons.business,
                    ),
                  if (service.reminderDate != null)
                    _buildInfoRow(
                      context,
                      'Reminder',
                      DateFormat.yMMMd().format(service.reminderDate!),
                      Icons.notifications,
                    ),
                  if (service.description.isNotEmpty) ...[
                    const Divider(),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(service.description),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
