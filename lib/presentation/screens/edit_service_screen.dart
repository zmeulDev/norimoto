import 'package:flutter/material.dart';
import 'package:norimoto/domain/models/service_record.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:norimoto/presentation/widgets/service_form.dart';
import 'package:norimoto/data/repositories/service_repository.dart';

class EditServiceScreen extends StatelessWidget {
  final ServiceRecord service;

  const EditServiceScreen({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'Edit Service'),
      body: ServiceForm(
        vehicleId: service.vehicleId,
        service: service,
        onSave: (updatedService) async {
          await ServiceRepository.updateService(updatedService);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Service updated successfully')),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
