import 'package:flutter/material.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/presentation/widgets/service_form.dart';
import 'package:norimoto/data/repositories/service_repository.dart';

class AddServiceScreen extends StatelessWidget {
  final String vehicleId;

  const AddServiceScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'Add Service'),
      body: ServiceForm(
        vehicleId: vehicleId,
        onSave: (service) async {
          await ServiceRepository.insertService(service);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Service added successfully')),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
