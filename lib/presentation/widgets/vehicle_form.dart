import 'package:flutter/material.dart';
import 'package:norimoto/domain/models/vehicle.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class VehicleForm extends StatefulWidget {
  final Vehicle? vehicle;
  final Function(Vehicle) onSave;

  const VehicleForm({
    super.key,
    this.vehicle,
    required this.onSave,
  });

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vinController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _colorController = TextEditingController();
  final _engineSizeController = TextEditingController();
  final _enginePowerController = TextEditingController();
  final _wheelsSizeController = TextEditingController();
  final _wiperSizeController = TextEditingController();
  final _lightsCodeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  Transmission _transmission = Transmission.manual;
  FuelType _fuelType = FuelType.petrol;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _makeController.text = widget.vehicle!.make;
      _modelController.text = widget.vehicle!.model;
      _yearController.text = widget.vehicle!.year.toString();
      _licensePlateController.text = widget.vehicle!.licensePlate;
      _vinController.text = widget.vehicle!.vin ?? '';
      _purchasePriceController.text = widget.vehicle!.purchasePrice.toString();
      _colorController.text = widget.vehicle!.color;
      _engineSizeController.text = widget.vehicle!.engineSize ?? '';
      _enginePowerController.text = widget.vehicle!.enginePower ?? '';
      _wheelsSizeController.text = widget.vehicle!.wheelsSize ?? '';
      _wiperSizeController.text = widget.vehicle!.wiperSize ?? '';
      _lightsCodeController.text = widget.vehicle!.lightsCode ?? '';
      _notesController.text = widget.vehicle!.notes;
      _purchaseDate = widget.vehicle!.purchaseDate;
      _transmission = widget.vehicle!.transmission;
      _fuelType = widget.vehicle!.fuelType;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Basic Information',
            children: [
              _buildTextField(
                controller: _makeController,
                label: 'Make',
                required: true,
                textCapitalization: TextCapitalization.words,
              ),
              _buildTextField(
                controller: _modelController,
                label: 'Model',
                required: true,
                textCapitalization: TextCapitalization.words,
              ),
              _buildTextField(
                controller: _yearController,
                label: 'Year',
                required: true,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter the year';
                  final year = int.tryParse(value!);
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year + 1) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _colorController,
                label: 'Color',
                required: true,
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
          _buildSection(
            title: 'Technical Details',
            children: [
              _buildDropdownField<Transmission>(
                value: _transmission,
                label: 'Transmission',
                items: Transmission.values,
                onChanged: (value) => setState(() => _transmission = value!),
              ),
              _buildDropdownField<FuelType>(
                value: _fuelType,
                label: 'Fuel Type',
                items: FuelType.values,
                onChanged: (value) => setState(() => _fuelType = value!),
              ),
              _buildTextField(
                controller: _engineSizeController,
                label: 'Engine Size',
                hint: 'e.g., 2.0L',
              ),
              _buildTextField(
                controller: _enginePowerController,
                label: 'Engine Power',
                hint: 'e.g., 150 HP',
              ),
            ],
          ),
          _buildSection(
            title: 'Identification',
            children: [
              _buildTextField(
                controller: _licensePlateController,
                label: 'License Plate',
                textCapitalization: TextCapitalization.characters,
              ),
              _buildTextField(
                controller: _vinController,
                label: 'VIN Number',
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
          _buildSection(
            title: 'Maintenance Information',
            children: [
              _buildTextField(
                controller: _wheelsSizeController,
                label: 'Wheels Size',
                hint: 'e.g., 225/45 R17',
              ),
              _buildTextField(
                controller: _wiperSizeController,
                label: 'Wiper Size',
                hint: 'e.g., 24" + 18"',
              ),
              _buildTextField(
                controller: _lightsCodeController,
                label: 'Lights Code',
                hint: 'e.g., H7/H1',
              ),
            ],
          ),
          _buildSection(
            title: 'Purchase Information',
            children: [
              _buildTextField(
                controller: _purchasePriceController,
                label: 'Purchase Price',
                keyboardType: TextInputType.number,
                prefix: '\$',
              ),
              ListTile(
                title: const Text('Purchase Date'),
                subtitle: Text(DateFormat.yMMMd().format(_purchaseDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
            ],
          ),
          _buildSection(
            title: 'Additional Notes',
            children: [
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _saveVehicle,
            icon: const Icon(Icons.save),
            label:
                Text(widget.vehicle == null ? 'Add Vehicle' : 'Update Vehicle'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children
                  .map((child) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: child,
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
    String? prefix,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        prefixText: prefix,
      ),
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator ??
          (required
              ? (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter the $label';
                  }
                  return null;
                }
              : null),
    );
  }

  Widget _buildDropdownField<T extends Enum>({
    required T value,
    required String label,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item.name.toUpperCase()),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
    }
  }

  void _saveVehicle() {
    if (_formKey.currentState?.validate() ?? false) {
      final vehicle = Vehicle(
        id: widget.vehicle?.id ?? const Uuid().v4(),
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.tryParse(_yearController.text.trim()) ?? DateTime.now().year,
        licensePlate: _licensePlateController.text.trim(),
        vin: _vinController.text.trim().isNotEmpty
            ? _vinController.text.trim()
            : null,
        purchaseDate: _purchaseDate,
        purchasePrice:
            double.tryParse(_purchasePriceController.text.trim()) ?? 0,
        color: _colorController.text.trim(),
        transmission: _transmission,
        fuelType: _fuelType,
        engineSize: _engineSizeController.text.trim().isNotEmpty
            ? _engineSizeController.text.trim()
            : null,
        enginePower: _enginePowerController.text.trim().isNotEmpty
            ? _enginePowerController.text.trim()
            : null,
        wheelsSize: _wheelsSizeController.text.trim().isNotEmpty
            ? _wheelsSizeController.text.trim()
            : null,
        wiperSize: _wiperSizeController.text.trim().isNotEmpty
            ? _wiperSizeController.text.trim()
            : null,
        lightsCode: _lightsCodeController.text.trim().isNotEmpty
            ? _lightsCodeController.text.trim()
            : null,
        notes: _notesController.text.trim(),
      );
      widget.onSave(vehicle);
    }
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    _purchasePriceController.dispose();
    _colorController.dispose();
    _engineSizeController.dispose();
    _enginePowerController.dispose();
    _wheelsSizeController.dispose();
    _wiperSizeController.dispose();
    _lightsCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
