import 'package:flutter/material.dart';
import 'package:norimoto/domain/models/vehicle.dart';
import 'package:norimoto/data/repositories/vehicle_repository.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/presentation/widgets/vehicle_form.dart';

class EditVehicleScreen extends StatelessWidget {
  final Vehicle vehicle;

  const EditVehicleScreen({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'Edit Vehicle'),
      body: VehicleForm(
        vehicle: vehicle,
        onSave: (updatedVehicle) async {
          await VehicleRepository.updateVehicle(updatedVehicle);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vehicle updated successfully')),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
