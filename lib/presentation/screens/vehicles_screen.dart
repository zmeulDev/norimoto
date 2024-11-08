import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/presentation/widgets/vehicle_list.dart';
import 'package:norimoto/presentation/screens/add_vehicle_screen.dart';
import 'package:norimoto/domain/models/vehicle.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  Future<void> _showAddVehicleOptions(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person),
                ),
                title: const Text('Personal Vehicle'),
                subtitle: const Text('Add your own vehicle'),
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
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.business),
                ),
                title: const Text('Company Vehicle'),
                subtitle: const Text('Add a company-assigned vehicle'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddVehicleScreen(
                        initialType: VehicleType.company,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
