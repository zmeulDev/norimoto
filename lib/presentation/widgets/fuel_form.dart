import 'package:flutter/material.dart';
import 'package:norimoto/domain/models/fuel_record.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class FuelForm extends StatefulWidget {
  final String vehicleId;
  final FuelRecord? record;
  final Function(FuelRecord) onSave;

  const FuelForm({
    super.key,
    required this.vehicleId,
    this.record,
    required this.onSave,
  });

  @override
  State<FuelForm> createState() => _FuelFormState();
}

class _FuelFormState extends State<FuelForm> {
  final _formKey = GlobalKey<FormState>();
  final _litersController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();
  final _stationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _fullTank = true;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _litersController.text = widget.record!.liters.toString();
      _costController.text = widget.record!.cost.toString();
      _odometerController.text = widget.record!.odometer.toString();
      _stationController.text = widget.record!.station ?? '';
      _notesController.text = widget.record!.notes ?? '';
      _fullTank = widget.record!.fullTank;
      _date = widget.record!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _litersController,
                          decoration: const InputDecoration(
                            labelText: 'Liters',
                            border: OutlineInputBorder(),
                            suffixText: 'L',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            if (double.tryParse(value!) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _costController,
                          decoration: const InputDecoration(
                            labelText: 'Total Cost',
                            border: OutlineInputBorder(),
                            prefixText: '\$',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Required';
                            if (double.tryParse(value!) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _odometerController,
                    decoration: const InputDecoration(
                      labelText: 'Odometer',
                      border: OutlineInputBorder(),
                      suffixText: 'km',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Required';
                      if (int.tryParse(value!) == null) {
                        return 'Invalid number';
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
            child: Column(
              children: [
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat.yMMMd().format(_date)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _date = picked);
                    }
                  },
                ),
                SwitchListTile(
                  title: const Text('Full Tank'),
                  subtitle: const Text('Was this a full tank fill-up?'),
                  value: _fullTank,
                  onChanged: (value) => setState(() => _fullTank = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _stationController,
                    decoration: const InputDecoration(
                      labelText: 'Station (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., Shell, BP',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                      hintText: 'Any additional notes',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saveFuelRecord,
            icon: const Icon(Icons.save),
            label: Text(widget.record == null ? 'Add Record' : 'Update Record'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  void _saveFuelRecord() {
    if (_formKey.currentState?.validate() ?? false) {
      final record = FuelRecord(
        id: widget.record?.id ?? const Uuid().v4(),
        vehicleId: widget.vehicleId,
        date: _date,
        liters: double.parse(_litersController.text),
        cost: double.parse(_costController.text),
        odometer: int.parse(_odometerController.text),
        fullTank: _fullTank,
        station:
            _stationController.text.isEmpty ? null : _stationController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      widget.onSave(record);
    }
  }

  @override
  void dispose() {
    _litersController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    _stationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
