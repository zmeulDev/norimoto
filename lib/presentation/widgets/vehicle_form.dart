import 'package:flutter/material.dart';
import 'package:norimoto/domain/models/vehicle.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class VehicleForm extends StatefulWidget {
  final Vehicle? vehicle;
  final VehicleType? initialType;
  final Function(Vehicle) onSave;

  const VehicleForm({
    super.key,
    this.vehicle,
    this.initialType,
    required this.onSave,
  });

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  int _currentStep = 0;
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
  final _companyNameController = TextEditingController();
  final _employeeIdController = TextEditingController();

  DateTime _purchaseDate = DateTime.now();
  Transmission _transmission = Transmission.manual;
  FuelType _fuelType = FuelType.petrol;
  VehicleType _type = VehicleType.personal;
  DateTime? _assignmentDate;

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
      _type = widget.vehicle!.type;
      _companyNameController.text = widget.vehicle!.companyName ?? '';
      _employeeIdController.text = widget.vehicle!.employeeId ?? '';
      _assignmentDate = widget.vehicle!.assignmentDate;
    } else if (widget.initialType != null) {
      _type = widget.initialType!;
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Vehicle Type
        if (_type == VehicleType.company) {
          return _companyNameController.text.isNotEmpty;
        }
        return true;
      case 1: // Basic Information
        return _makeController.text.isNotEmpty &&
            _modelController.text.isNotEmpty &&
            _yearController.text.isNotEmpty &&
            _colorController.text.isNotEmpty &&
            (int.tryParse(_yearController.text) != null &&
                int.parse(_yearController.text) >= 1900 &&
                int.parse(_yearController.text) <= DateTime.now().year + 1);
      case 2: // Technical Details
        return true; // Optional fields
      case 3: // Maintenance Info
        return true; // Optional fields
      case 4: // Purchase Details
        return _purchasePriceController.text.isNotEmpty &&
            double.tryParse(_purchasePriceController.text) != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_validateCurrentStep()) {
            if (_currentStep < 4) {
              setState(() => _currentStep++);
            } else {
              _saveVehicle();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_getValidationMessage()),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == 4;
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: details.onStepContinue,
                    child: Text(isLastStep ? 'Save Vehicle' : 'Continue'),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Vehicle Type'),
            content: _buildVehicleType(),
            isActive: _currentStep >= 0,
            state: _getStepState(0),
          ),
          Step(
            title: const Text('Basic Information'),
            content: _buildBasicInfo(),
            isActive: _currentStep >= 1,
            state: _getStepState(1),
          ),
          Step(
            title: const Text('Technical Details'),
            content: _buildTechnicalInfo(),
            isActive: _currentStep >= 2,
            state: _getStepState(2),
          ),
          Step(
            title: const Text('Maintenance Info'),
            content: _buildMaintenanceInfo(),
            isActive: _currentStep >= 3,
            state: _getStepState(3),
          ),
          Step(
            title: const Text('Purchase Details'),
            content: Column(
              children: [
                _buildPurchaseInfo(),
                const SizedBox(height: 16),
                _buildNotesInfo(),
              ],
            ),
            isActive: _currentStep >= 4,
            state: _getStepState(4),
          ),
        ],
      ),
    );
  }

  StepState _getStepState(int step) {
    if (_currentStep > step) {
      return _validateStep(step) ? StepState.complete : StepState.error;
    }
    return StepState.indexed;
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (_type == VehicleType.company) {
          return _companyNameController.text.isNotEmpty;
        }
        return true;
      case 1:
        return _makeController.text.isNotEmpty &&
            _modelController.text.isNotEmpty &&
            _yearController.text.isNotEmpty &&
            _colorController.text.isNotEmpty;
      case 2:
        return true; // Optional fields
      case 3:
        return true; // Optional fields
      case 4:
        return _purchasePriceController.text.isNotEmpty;
      default:
        return false;
    }
  }

  String _getValidationMessage() {
    switch (_currentStep) {
      case 0:
        if (_type == VehicleType.company &&
            _companyNameController.text.isEmpty) {
          return 'Please enter the company name';
        }
        return 'Please fill in all required fields';
      case 1:
        if (_makeController.text.isEmpty) return 'Please enter the make';
        if (_modelController.text.isEmpty) return 'Please enter the model';
        if (_yearController.text.isEmpty) return 'Please enter the year';
        if (_colorController.text.isEmpty) return 'Please enter the color';
        if (int.tryParse(_yearController.text) == null) {
          return 'Please enter a valid year';
        }
        final year = int.parse(_yearController.text);
        if (year < 1900 || year > DateTime.now().year + 1) {
          return 'Please enter a valid year between 1900 and ${DateTime.now().year + 1}';
        }
        return 'Please fill in all required fields';
      case 4:
        if (_purchasePriceController.text.isEmpty) {
          return 'Please enter the purchase price';
        }
        if (double.tryParse(_purchasePriceController.text) == null) {
          return 'Please enter a valid purchase price';
        }
        return 'Please fill in all required fields';
      default:
        return 'Please fill in all required fields';
    }
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTextField(
                  controller: _makeController,
                  label: 'Make',
                  required: true,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _modelController,
                  label: 'Model',
                  required: true,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _yearController,
                        label: 'Year',
                        required: true,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          final year = int.tryParse(value!);
                          if (year == null ||
                              year < 1900 ||
                              year > DateTime.now().year + 1) {
                            return 'Invalid year';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _colorController,
                        label: 'Color',
                        required: true,
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleType() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: Radio<VehicleType>(
              value: VehicleType.personal,
              groupValue: _type,
              onChanged: (value) => setState(() => _type = value!),
            ),
            title: const Text('Personal Vehicle'),
            subtitle: const Text('Your own private vehicle'),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person),
            ),
            onTap: () => setState(() => _type = VehicleType.personal),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Radio<VehicleType>(
              value: VehicleType.company,
              groupValue: _type,
              onChanged: (value) => setState(() => _type = value!),
            ),
            title: const Text('Company Vehicle'),
            subtitle: const Text('Vehicle assigned by your company'),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business),
            ),
            onTap: () => setState(() => _type = VehicleType.company),
          ),
        ),
        if (_type == VehicleType.company) ...[
          const SizedBox(height: 16),
          _buildCompanyInfo(),
        ],
      ],
    );
  }

  Widget _buildCompanyInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'Company Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (_type == VehicleType.company && (value?.isEmpty ?? true)) {
                  return 'Please enter the company name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _employeeIdController,
              decoration: const InputDecoration(
                labelText: 'Employee ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _assignmentDate == null
                    ? 'Select Assignment Date'
                    : DateFormat.yMMMd().format(_assignmentDate!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _assignmentDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _assignmentDate = picked);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField<Transmission>(
                        value: _transmission,
                        label: 'Transmission',
                        items: Transmission.values,
                        onChanged: (value) =>
                            setState(() => _transmission = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField<FuelType>(
                        value: _fuelType,
                        label: 'Fuel Type',
                        items: FuelType.values,
                        onChanged: (value) =>
                            setState(() => _fuelType = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _engineSizeController,
                        label: 'Engine Size',
                        hint: 'e.g., 2.0L',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _enginePowerController,
                        label: 'Engine Power',
                        hint: 'e.g., 150 HP',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Maintenance Information',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _wheelsSizeController,
                        label: 'Wheels Size',
                        hint: 'e.g., 225/45 R17',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _wiperSizeController,
                        label: 'Wiper Size',
                        hint: 'e.g., 24" + 18"',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _lightsCodeController,
                  label: 'Lights Code',
                  hint: 'e.g., H7/H1',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purchase Information',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTextField(
                  controller: _purchasePriceController,
                  label: 'Purchase Price',
                  keyboardType: TextInputType.number,
                  prefix: '\$',
                  required: true,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Purchase Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat.yMMMd().format(_purchaseDate)),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: Theme.of(context).textTheme.titleMedium,
        ),
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
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item.name.toUpperCase(),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
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
        type: _type,
        companyName: _type == VehicleType.company
            ? _companyNameController.text.trim()
            : null,
        employeeId: _type == VehicleType.company
            ? _employeeIdController.text.trim()
            : null,
        assignmentDate: _type == VehicleType.company ? _assignmentDate : null,
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
    _companyNameController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }
}
