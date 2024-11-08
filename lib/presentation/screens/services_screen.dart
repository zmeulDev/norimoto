import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/data/repositories/service_repository.dart';
import 'package:norimoto/domain/models/service_record.dart';
import 'package:norimoto/data/repositories/vehicle_repository.dart';
import 'package:norimoto/domain/models/vehicle.dart';
import 'package:intl/intl.dart';
import 'package:norimoto/presentation/screens/service_details_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    ServiceRepository.getAllServices();
    VehicleRepository.getAllVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(
        title: 'All Services',
      ),
      body: StreamBuilder<List<Vehicle>>(
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

              final services = serviceSnapshot.data ?? [];
              final vehicles = vehicleSnapshot.data ?? [];

              if (services.isEmpty) {
                return const Center(
                  child: Text('No service records found'),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
    );
  }
}
