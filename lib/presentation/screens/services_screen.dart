import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/data/repositories/service_repository.dart';
import 'package:norimoto/domain/models/service_record.dart';
import 'package:norimoto/data/repositories/vehicle_repository.dart';
import 'package:norimoto/domain/models/vehicle.dart';
import 'package:intl/intl.dart';
import 'package:norimoto/presentation/screens/service_details_screen.dart';
import 'package:norimoto/presentation/screens/add_service_screen.dart';
import 'package:norimoto/domain/models/service_type.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  ServiceType? _selectedType;
  DateTimeRange? _dateRange;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    ServiceRepository.getAllServices();
    VehicleRepository.getAllVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: 'All Services',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showVehicleSelectionDialog(context),
            tooltip: 'Add Service',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_showFilters) ...[
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<ServiceType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Service Type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Types'),
                        ),
                        ...ServiceType.values.map((type) => DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(type.icon),
                                  const SizedBox(width: 8),
                                  Text(type.displayName),
                                ],
                              ),
                            )),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedType = value),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(_dateRange == null
                          ? 'Select Date Range'
                          : '${DateFormat.yMMMd().format(_dateRange!.start)} - ${DateFormat.yMMMd().format(_dateRange!.end)}'),
                      trailing: _dateRange != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => _dateRange = null),
                            )
                          : const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          initialDateRange: _dateRange ??
                              DateTimeRange(
                                start: DateTime.now()
                                    .subtract(const Duration(days: 30)),
                                end: DateTime.now(),
                              ),
                        );
                        if (picked != null) {
                          setState(() => _dateRange = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: StreamBuilder<List<Vehicle>>(
              stream: VehicleRepository.vehiclesStream,
              initialData: const [],
              builder: (context, vehicleSnapshot) {
                return StreamBuilder<List<ServiceRecord>>(
                  stream: ServiceRepository.servicesStream,
                  initialData: const [],
                  builder: (context, serviceSnapshot) {
                    if (serviceSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${serviceSnapshot.error}'),
                      );
                    }

                    var services = serviceSnapshot.data ?? [];
                    final vehicles = vehicleSnapshot.data ?? [];

                    // Apply filters
                    services = services.where((service) {
                      // Search filter
                      if (_searchController.text.isNotEmpty) {
                        final search = _searchController.text.toLowerCase();
                        if (!service.title.toLowerCase().contains(search) &&
                            !service.description
                                .toLowerCase()
                                .contains(search)) {
                          return false;
                        }
                      }

                      // Type filter
                      if (_selectedType != null &&
                          service.type != _selectedType) {
                        return false;
                      }

                      // Date range filter
                      if (_dateRange != null) {
                        if (service.date.isBefore(_dateRange!.start) ||
                            service.date.isAfter(_dateRange!.end)) {
                          return false;
                        }
                      }

                      return true;
                    }).toList();

                    if (services.isEmpty) {
                      return const Center(
                        child: Text('No matching service records found'),
                      );
                    }

                    // Sort services by date, newest first
                    services.sort((a, b) => b.date.compareTo(a.date));

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        final vehicle = vehicles.firstWhere(
                          (v) => v.id == service.vehicleId,
                          orElse: () => Vehicle(
                            id: '',
                            make: 'Unknown',
                            model: 'Vehicle',
                            year: 0,
                            licensePlate: '',
                            purchaseDate: DateTime.now(),
                            purchasePrice: 0,
                            color: '',
                            transmission: Transmission.manual,
                            fuelType: FuelType.petrol,
                          ),
                        );

                        return Card(
                          child: ListTile(
                            leading: Icon(
                              service.type.icon,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(service.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${vehicle.year} ${vehicle.make} ${vehicle.model}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(DateFormat.yMMMd().format(service.date)),
                                Text(NumberFormat.currency(symbol: '\$')
                                    .format(service.cost)),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: service.reminderDate != null
                                ? const Icon(Icons.notifications_active)
                                : null,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ServiceDetailsScreen(
                                    service: service,
                                    vehicle: vehicle,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showVehicleSelectionDialog(BuildContext context) async {
    final vehicles = await VehicleRepository.getAllVehicles();

    if (!mounted) return;

    if (vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a vehicle first'),
        ),
      );
      return;
    }

    if (vehicles.length == 1) {
      // If there's only one vehicle, go directly to add service screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddServiceScreen(
              vehicleId: vehicles.first.id,
            ),
          ),
        );
      }
      return;
    }

    // Show vehicle selection dialog if there are multiple vehicles
    if (mounted) {
      final selectedVehicle = await showDialog<Vehicle>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Vehicle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: vehicles
                  .map((vehicle) => ListTile(
                        title: Text(
                            '${vehicle.year} ${vehicle.make} ${vehicle.model}'),
                        subtitle: Text(vehicle.licensePlate),
                        onTap: () => Navigator.pop(context, vehicle),
                      ))
                  .toList(),
            ),
          ),
        ),
      );

      if (selectedVehicle != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddServiceScreen(
              vehicleId: selectedVehicle.id,
            ),
          ),
        );
      }
    }
  }
}
