import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/presentation/widgets/vehicle_list.dart';
import 'package:norimoto/presentation/screens/add_vehicle_screen.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  void _showAddVehicleOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Add New Vehicle',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.directions_car),
                ),
                title: const Text('Personal Vehicle'),
                subtitle: const Text('Add your own car, motorcycle, etc.'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddVehicleScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.business),
                ),
                title: const Text('Company Vehicle'),
                subtitle: const Text('Add a company or fleet vehicle'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement company vehicle addition
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Company vehicle support coming soon'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SharedAppBar(
        title: 'My Vehicles',
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cloud backup coming soon'),
                ),
              );
            },
            tooltip: 'Backup to Cloud',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddVehicleOptions(context),
            tooltip: 'Add Vehicle',
          ),
        ],
      ),
      body: const VehicleList(),
    );
  }
}
