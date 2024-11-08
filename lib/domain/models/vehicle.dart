enum Transmission { manual, automatic, other }

enum FuelType { petrol, diesel, electric, hybrid, lpg, other }

class Vehicle {
  final String id;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String? vin;
  final DateTime purchaseDate;
  final double purchasePrice;
  final String color;
  final Transmission transmission;
  final FuelType fuelType;
  final String? engineSize;
  final String? enginePower;
  final String? wheelsSize;
  final String? wiperSize;
  final String? lightsCode;
  final String notes;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.vin,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.color,
    required this.transmission,
    required this.fuelType,
    this.engineSize,
    this.enginePower,
    this.wheelsSize,
    this.wiperSize,
    this.lightsCode,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        'model': model,
        'year': year,
        'licensePlate': licensePlate,
        'vin': vin,
        'purchaseDate': purchaseDate.toIso8601String(),
        'purchasePrice': purchasePrice,
        'color': color,
        'transmission': transmission.name,
        'fuelType': fuelType.name,
        'engineSize': engineSize,
        'enginePower': enginePower,
        'wheelsSize': wheelsSize,
        'wiperSize': wiperSize,
        'lightsCode': lightsCode,
        'notes': notes,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      licensePlate: json['licensePlate'] as String,
      vin: json['vin'] as String?,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      color: json['color'] as String,
      transmission: Transmission.values.byName(json['transmission'] as String),
      fuelType: FuelType.values.byName(json['fuelType'] as String),
      engineSize: json['engineSize'] as String?,
      enginePower: json['enginePower'] as String?,
      wheelsSize: json['wheelsSize'] as String?,
      wiperSize: json['wiperSize'] as String?,
      lightsCode: json['lightsCode'] as String?,
      notes: (json['notes'] as String?) ?? '',
    );
  }

  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? vin,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? color,
    Transmission? transmission,
    FuelType? fuelType,
    String? engineSize,
    String? enginePower,
    String? wheelsSize,
    String? wiperSize,
    String? lightsCode,
    String? notes,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      vin: vin ?? this.vin,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      color: color ?? this.color,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      engineSize: engineSize ?? this.engineSize,
      enginePower: enginePower ?? this.enginePower,
      wheelsSize: wheelsSize ?? this.wheelsSize,
      wiperSize: wiperSize ?? this.wiperSize,
      lightsCode: lightsCode ?? this.lightsCode,
      notes: notes ?? this.notes,
    );
  }
}
