import 'package:flutter/material.dart';
import 'package:norimoto/domain/models/fuel_record.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/presentation/widgets/fuel_form.dart';
import 'package:norimoto/data/repositories/fuel_repository.dart';

class EditFuelRecordScreen extends StatelessWidget {
  final FuelRecord record;

  const EditFuelRecordScreen({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'Edit Fuel Record'),
      body: FuelForm(
        vehicleId: record.vehicleId,
        record: record,
        onSave: (updatedRecord) async {
          await FuelRepository.updateFuelRecord(updatedRecord);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fuel record updated successfully')),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
