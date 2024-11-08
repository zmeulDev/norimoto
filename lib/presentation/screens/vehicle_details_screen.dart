import 'package:flutter/material.dart';
import 'package:norimoto/domain/models/vehicle.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:norimoto/presentation/widgets/service_list.dart';
import 'package:norimoto/presentation/screens/add_service_screen.dart';
import 'package:norimoto/presentation/screens/schedule_service_screen.dart';
import 'package:norimoto/presentation/widgets/fuel_list.dart';
import 'package:norimoto/data/repositories/service_repository.dart';
import 'package:norimoto/data/repositories/fuel_repository.dart';
import 'package:norimoto/domain/models/service_record.dart';
import 'package:norimoto/domain/models/fuel_record.dart';
import 'package:norimoto/presentation/widgets/cost_statistics.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize data streams once
    ServiceRepository.getAllServices();
    FuelRepository.getAllFuelRecords();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: SharedAppBar(
          title:
              '${widget.vehicle.year} ${widget.vehicle.make} ${widget.vehicle.model}',
          bottom: TabBar(
            onTap: (index) => setState(() => _currentTabIndex = index),
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Services'),
              Tab(text: 'Fuel'),
              Tab(text: 'Costs'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: Navigate to edit screen
              },
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Text('Export Data'),
                ),
                const PopupMenuItem(
                  value: 'schedule',
                  child: Text('Schedule Service'),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'export':
                    // TODO: Implement export
                    break;
                  case 'schedule':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleServiceScreen(
                          vehicleId: widget.vehicle.id,
                        ),
                      ),
                    );
                    break;
                }
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildDetailsTab(),
            _buildServicesTab(),
            _buildFuelTab(),
            _buildCostsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          title: 'Vehicle Information',
          items: [
            InfoItem('Make', widget.vehicle.make),
            InfoItem('Model', widget.vehicle.model),
            InfoItem('Year', widget.vehicle.year.toString()),
            InfoItem('Color', widget.vehicle.color),
            if (widget.vehicle.licensePlate.isNotEmpty)
              InfoItem('License Plate', widget.vehicle.licensePlate),
            if (widget.vehicle.vin != null)
              InfoItem('VIN', widget.vehicle.vin!),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Technical Details',
          items: [
            InfoItem(
                'Transmission', widget.vehicle.transmission.name.toUpperCase()),
            InfoItem('Fuel Type', widget.vehicle.fuelType.name.toUpperCase()),
            if (widget.vehicle.engineSize != null)
              InfoItem('Engine Size', widget.vehicle.engineSize!),
            if (widget.vehicle.enginePower != null)
              InfoItem('Engine Power', widget.vehicle.enginePower!),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Maintenance Information',
          items: [
            if (widget.vehicle.wheelsSize != null)
              InfoItem('Wheels Size', widget.vehicle.wheelsSize!),
            if (widget.vehicle.wiperSize != null)
              InfoItem('Wiper Size', widget.vehicle.wiperSize!),
            if (widget.vehicle.lightsCode != null)
              InfoItem('Lights Code', widget.vehicle.lightsCode!),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Purchase Information',
          items: [
            InfoItem(
              'Purchase Date',
              DateFormat.yMMMd().format(widget.vehicle.purchaseDate),
            ),
            InfoItem(
              'Purchase Price',
              NumberFormat.currency(symbol: '\$')
                  .format(widget.vehicle.purchasePrice),
            ),
          ],
        ),
        if (widget.vehicle.notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'Notes',
            items: [InfoItem('', widget.vehicle.notes)],
          ),
        ],
      ],
    );
  }

  Widget _buildServicesTab() {
    return ServiceList(vehicleId: widget.vehicle.id);
  }

  Widget _buildFuelTab() {
    return FuelList(vehicleId: widget.vehicle.id);
  }

  Widget _buildCostsTab() {
    return StreamBuilder<List<ServiceRecord>>(
      stream: ServiceRepository.servicesStream,
      initialData: const [],
      builder: (context, serviceSnapshot) {
        return StreamBuilder<List<FuelRecord>>(
          stream: FuelRepository.fuelRecordsStream,
          initialData: const [],
          builder: (context, fuelSnapshot) {
            if (serviceSnapshot.hasError || fuelSnapshot.hasError) {
              debugPrint(
                  'Error in streams: ${serviceSnapshot.error ?? fuelSnapshot.error}');
              return Center(
                child: Text(
                    'Error: ${serviceSnapshot.error ?? fuelSnapshot.error}'),
              );
            }

            final services = serviceSnapshot.data ?? [];
            final fuels = fuelSnapshot.data ?? [];

            debugPrint('Current vehicle ID: ${widget.vehicle.id}');
            debugPrint('All services: ${services.length}');
            debugPrint('All fuels: ${fuels.length}');

            // Print all fuel records vehicleIds for debugging
            for (var fuel in fuels) {
              debugPrint('Fuel record vehicleId: ${fuel.vehicleId}');
            }

            final vehicleServices = services
                .where((s) => s.vehicleId == widget.vehicle.id)
                .toList();
            final vehicleFuels =
                fuels.where((f) => f.vehicleId == widget.vehicle.id).toList();

            debugPrint('Vehicle services: ${vehicleServices.length}');
            debugPrint('Vehicle fuels: ${vehicleFuels.length}');

            // Print some sample data to verify filtering
            if (vehicleServices.isNotEmpty) {
              debugPrint(
                  'Sample service vehicleId: ${vehicleServices.first.vehicleId}');
            }
            if (vehicleFuels.isNotEmpty) {
              debugPrint(
                  'Sample fuel vehicleId: ${vehicleFuels.first.vehicleId}');
            }

            if (vehicleServices.isEmpty && vehicleFuels.isEmpty) {
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
                          Icons.analytics_outlined,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Cost Data',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Add service records or fuel records to see cost statistics',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return CostStatistics(
              vehicleId: widget.vehicle.id,
              serviceRecords: vehicleServices,
              fuelRecords: vehicleFuels,
            );
          },
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<InfoItem> items,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => _buildInfoRow(item.label, item.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class InfoItem {
  final String label;
  final String value;

  InfoItem(this.label, this.value);
}
