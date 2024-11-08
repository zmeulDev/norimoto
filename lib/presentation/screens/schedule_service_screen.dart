import 'package:flutter/material.dart';
import 'package:norimoto/core/services/notification_service.dart';
import 'package:norimoto/data/repositories/service_repository.dart';
import 'package:norimoto/domain/models/service_record.dart';
import 'package:norimoto/domain/models/service_type.dart';
import 'package:norimoto/presentation/widgets/shared/app_bar.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ScheduleServiceScreen extends StatefulWidget {
  final String vehicleId;

  const ScheduleServiceScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<ScheduleServiceScreen> createState() => _ScheduleServiceScreenState();
}

class _ScheduleServiceScreenState extends State<ScheduleServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mileageController = TextEditingController();
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 7));
  ServiceType _type = ServiceType.maintenance;
  bool _isRecurring = false;
  int? _recurringMonths;
  int? _recurringKilometers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: 'Schedule Service'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<ServiceType>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: 'Service Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ServiceType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(type.icon),
                              const SizedBox(width: 8),
                              Text(type.displayName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _type = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _mileageController,
                      decoration: const InputDecoration(
                        labelText: 'Expected Mileage',
                        border: OutlineInputBorder(),
                        suffixText: 'km',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter expected mileage';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Scheduled Date'),
                      subtitle: Text(DateFormat.yMMMd().format(_scheduledDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Recurring Service'),
                      value: _isRecurring,
                      onChanged: (value) {
                        setState(() {
                          _isRecurring = value;
                          if (!value) {
                            _recurringMonths = null;
                            _recurringKilometers = null;
                          }
                        });
                      },
                    ),
                    if (_isRecurring) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Repeat Every (Months)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _recurringMonths = int.tryParse(value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Repeat Every (Kilometers)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _recurringKilometers = int.tryParse(value);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _scheduleService,
              icon: const Icon(Icons.schedule),
              label: const Text('Schedule Service'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _scheduleService() async {
    if (_formKey.currentState?.validate() ?? false) {
      final service = ServiceRecord(
        id: const Uuid().v4(),
        vehicleId: widget.vehicleId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _scheduledDate,
        reminderDate: _scheduledDate.subtract(const Duration(days: 7)),
        cost: 0,
        mileage: int.parse(_mileageController.text),
        serviceProvider: '',
        type: _type,
        isScheduled: true,
        isRecurring: _isRecurring,
        recurringMonths: _recurringMonths,
        recurringKilometers: _recurringKilometers,
      );

      await ServiceRepository.insertService(service);

      // Schedule notification
      await NotificationService.scheduleServiceReminder(
        id: service.id,
        title: 'Service Reminder',
        body: 'Upcoming service: ${service.title}',
        scheduledDate: service.reminderDate!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service scheduled successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mileageController.dispose();
    super.dispose();
  }
}
