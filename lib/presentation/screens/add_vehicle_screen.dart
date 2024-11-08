import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/data/repositories/vehicle_repository.dart';
import 'package:norimoto/presentation/widgets/vehicle_form.dart';

class AddVehicleScreen extends StatelessWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'Add Vehicle'),
      body: VehicleForm(
        onSave: (vehicle) async {
          await VehicleRepository.insertVehicle(vehicle);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vehicle added successfully')),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
