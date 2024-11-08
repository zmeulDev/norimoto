import 'package:flutter/material.dart';
import 'package:norimoto/domain/models/service_record.dart';
import 'package:norimoto/domain/models/service_type.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ServiceForm extends StatefulWidget {
  final String vehicleId;
  final ServiceRecord? service;
  final Function(ServiceRecord) onSave;

  const ServiceForm({
    super.key,
    required this.vehicleId,
    this.service,
    required this.onSave,
  });

  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _mileageController = TextEditingController();
  final _serviceProviderController = TextEditingController();

  late DateTime _date;
  DateTime? _reminderDate;
  late ServiceType _type;
  bool _isRecurring = false;
  int? _recurringMonths;
  int? _recurringKilometers;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _titleController.text = widget.service!.title;
      _descriptionController.text = widget.service!.description;
      _costController.text = widget.service!.cost.toString();
      _mileageController.text = widget.service!.mileage.toString();
      _serviceProviderController.text = widget.service!.serviceProvider;
      _date = widget.service!.date;
      _reminderDate = widget.service!.reminderDate;
      _type = widget.service!.type;
      _isRecurring = widget.service!.isRecurring;
      _recurringMonths = widget.service!.recurringMonths;
      _recurringKilometers = widget.service!.recurringKilometers;
    } else {
      _date = DateTime.now();
      _type = ServiceType.maintenance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBasicInfo(),
          const SizedBox(height: 16),
          _buildSchedulingInfo(),
          const SizedBox(height: 16),
          _buildRecurringInfo(),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _saveService,
            icon: const Icon(Icons.save),
            label:
                Text(widget.service == null ? 'Add Service' : 'Update Service'),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                if (value?.isEmpty ?? true) return 'Please enter a title';
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costController,
                    decoration: const InputDecoration(
                      labelText: 'Cost',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Please enter the cost';
                      if (double.tryParse(value!) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _mileageController,
                    decoration: const InputDecoration(
                      labelText: 'Mileage',
                      border: OutlineInputBorder(),
                      suffixText: 'km',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Please enter the mileage';
                      if (int.tryParse(value!) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceProviderController,
              decoration: const InputDecoration(
                labelText: 'Service Provider',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulingInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Service Date'),
              subtitle: Text(DateFormat.yMMMd().format(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Set Reminder'),
              value: _reminderDate != null,
              onChanged: (value) {
                setState(() {
                  _reminderDate = value
                      ? DateTime.now().add(const Duration(days: 30))
                      : null;
                });
              },
            ),
            if (_reminderDate != null)
              ListTile(
                title: const Text('Reminder Date'),
                subtitle: Text(DateFormat.yMMMd().format(_reminderDate!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _reminderDate!,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _reminderDate = picked);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurringInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                initialValue: _recurringMonths?.toString(),
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
                initialValue: _recurringKilometers?.toString(),
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
    );
  }

  void _saveService() {
    if (_formKey.currentState?.validate() ?? false) {
      final service = ServiceRecord(
        id: widget.service?.id ?? const Uuid().v4(),
        vehicleId: widget.vehicleId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _date,
        reminderDate: _reminderDate,
        cost: double.parse(_costController.text),
        mileage: int.parse(_mileageController.text),
        serviceProvider: _serviceProviderController.text.trim(),
        type: _type,
        isRecurring: _isRecurring,
        recurringMonths: _recurringMonths,
        recurringKilometers: _recurringKilometers,
      );
      widget.onSave(service);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _mileageController.dispose();
    _serviceProviderController.dispose();
    super.dispose();
  }
}
