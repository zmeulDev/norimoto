import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/presentation/widgets/fuel_form.dart';
import 'package:norimoto/data/repositories/fuel_repository.dart';

class AddFuelRecordScreen extends StatelessWidget {
  final String vehicleId;

  const AddFuelRecordScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'Add Fuel Record'),
      body: FuelForm(
        vehicleId: vehicleId,
        onSave: (record) async {
          await FuelRepository.insertFuelRecord(record);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fuel record added successfully')),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
