import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/data/repositories/vehicle_repository.dart';
import 'package:norimoto/presentation/widgets/vehicle_form.dart';
import 'package:norimoto/domain/models/vehicle.dart';

class AddVehicleScreen extends StatelessWidget {
  final VehicleType? initialType;

  const AddVehicleScreen({
    super.key,
    this.initialType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'Add Vehicle'),
      body: VehicleForm(
        initialType: initialType,
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
