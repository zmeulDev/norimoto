import 'package:flutter/material.dart';
import 'package:norimoto/data/repositories/service_repository.dart';
import 'package:norimoto/domain/models/service_record.dart';
import 'package:intl/intl.dart';
import 'package:norimoto/presentation/screens/add_service_screen.dart';
import 'package:norimoto/presentation/screens/schedule_service_screen.dart';
import 'package:norimoto/presentation/screens/edit_service_screen.dart';

class ServiceList extends StatefulWidget {
  final String? vehicleId;

  const ServiceList({
    super.key,
    this.vehicleId,
  });

  @override
  State<ServiceList> createState() => _ServiceListState();
}

class _ServiceListState extends State<ServiceList> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    ServiceRepository.getAllServices();
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text('Add Service Record'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddServiceScreen(
                      vehicleId: widget.vehicleId!,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Schedule Service'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScheduleServiceScreen(
                      vehicleId: widget.vehicleId!,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ServiceRecord>>(
      stream: ServiceRepository.servicesStream,
      initialData: const [], // Add initial empty list to prevent loading state
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final services = snapshot.data ?? [];
        final filteredServices = widget.vehicleId != null
            ? services.where((s) => s.vehicleId == widget.vehicleId).toList()
            : services;

        if (filteredServices.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.build_circle_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Service Records',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.vehicleId != null
                        ? 'Start tracking maintenance by adding your first service record'
                        : 'No service records found for any vehicles',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  if (widget.vehicleId != null) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _showAddOptions(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Service Record'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredServices.length,
              itemBuilder: (context, index) {
                final service = filteredServices[index];
                return ServiceCard(service: service);
              },
            ),
            if (widget.vehicleId != null)
              Positioned(
                bottom: 16,
                right: 16,
                child: FilledButton.icon(
                  onPressed: () => _showAddOptions(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Service'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceRecord service;

  const ServiceCard({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              service.type.icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(service.title),
            subtitle: Text(service.type.displayName),
            trailing: service.isRecurring
                ? const Icon(Icons.repeat, color: Colors.blue)
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildInfoRow(
                  'Date',
                  dateFormat.format(service.date),
                  Icons.calendar_today,
                ),
                _buildInfoRow(
                  'Cost',
                  currencyFormat.format(service.cost),
                  Icons.attach_money,
                ),
                _buildInfoRow(
                  'Mileage',
                  '${NumberFormat('#,###').format(service.mileage)} km',
                  Icons.speed,
                ),
                if (service.serviceProvider.isNotEmpty)
                  _buildInfoRow(
                    'Provider',
                    service.serviceProvider,
                    Icons.business,
                  ),
                if (service.reminderDate != null)
                  _buildInfoRow(
                    'Reminder',
                    dateFormat.format(service.reminderDate!),
                    Icons.notifications,
                    color: _isReminderSoon(service.reminderDate!)
                        ? Colors.orange
                        : null,
                  ),
              ],
            ),
          ),
          ButtonBar(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
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
              TextButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Service'),
                      content: const Text(
                        'Are you sure you want to delete this service record? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed ?? false) {
                    await ServiceRepository.deleteService(service.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Service record deleted')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: color ?? Colors.grey),
          ),
          Text(value),
        ],
      ),
    );
  }

  bool _isReminderSoon(DateTime reminderDate) {
    final now = DateTime.now();
    final difference = reminderDate.difference(now);
    return difference.inDays <= 7 && difference.isNegative == false;
  }
}
