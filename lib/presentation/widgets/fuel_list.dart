import 'package:flutter/material.dart';
import 'package:norimoto/data/repositories/fuel_repository.dart';
import 'package:norimoto/domain/models/fuel_record.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:norimoto/presentation/screens/edit_fuel_record_screen.dart';
import 'package:norimoto/presentation/screens/add_fuel_record_screen.dart';
import 'package:norimoto/presentation/widgets/fuel_statistics.dart';

class FuelList extends StatefulWidget {
  final String vehicleId;

  const FuelList({
    super.key,
    required this.vehicleId,
  });

  @override
  State<FuelList> createState() => _FuelListState();
}

class _FuelListState extends State<FuelList> {
  @override
  void initState() {
    super.initState();
    FuelRepository.getAllFuelRecords();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FuelRecord>>(
      stream: FuelRepository.fuelRecordsStream,
      initialData: const [],
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final records = snapshot.data ?? [];
        final vehicleRecords =
            records.where((r) => r.vehicleId == widget.vehicleId).toList();

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Records'),
                  Tab(text: 'Statistics'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildRecordsList(vehicleRecords),
                    FuelStatistics(
                      vehicleId: widget.vehicleId,
                      records: vehicleRecords,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordsList(List<FuelRecord> records) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_gas_station_outlined,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Fuel Records',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Start tracking fuel consumption by adding your first fuel record',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddFuelRecordScreen(vehicleId: widget.vehicleId),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Fuel Record'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return FuelRecordCard(record: record);
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddFuelRecordScreen(vehicleId: widget.vehicleId),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Fuel'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FuelRecordCard extends StatelessWidget {
  final FuelRecord record;

  const FuelRecordCard({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat.yMMMd();
    final numberFormat = NumberFormat('#,##0.00');

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(record.date),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      currencyFormat.format(record.cost),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${numberFormat.format(record.liters)} L'),
                        Text(
                          '${currencyFormat.format(record.pricePerLiter)}/L',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            '${NumberFormat('#,###').format(record.odometer)} km'),
                        if (record.station != null)
                          Text(
                            record.station!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
                if (record.notes?.isNotEmpty ?? false) ...[
                  const Divider(),
                  Text(
                    record.notes!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          ButtonBar(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditFuelRecordScreen(record: record),
                    ),
                  );
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Fuel Record'),
                      content: const Text(
                        'Are you sure you want to delete this fuel record? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed ?? false) {
                    await FuelRepository.deleteFuelRecord(record.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fuel record deleted')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddFuelRecordForm extends StatefulWidget {
  final String vehicleId;

  const AddFuelRecordForm({
    super.key,
    required this.vehicleId,
  });

  @override
  State<AddFuelRecordForm> createState() => _AddFuelRecordFormState();
}

class _AddFuelRecordFormState extends State<AddFuelRecordForm> {
  final _formKey = GlobalKey<FormState>();
  final _litersController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();
  final _stationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _fullTank = true;
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Fuel Record',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
              value: _fullTank,
              onChanged: (value) => setState(() => _fullTank = value),
            ),
            TextFormField(
              controller: _stationController,
              decoration: const InputDecoration(
                labelText: 'Station (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveFuelRecord,
              child: const Text('Save'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _saveFuelRecord() async {
    if (_formKey.currentState?.validate() ?? false) {
      final record = FuelRecord(
        id: const Uuid().v4(),
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

      await FuelRepository.insertFuelRecord(record);
      if (mounted) {
        Navigator.pop(context);
      }
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
