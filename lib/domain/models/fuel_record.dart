class FuelRecord {
  final String id;
  final String vehicleId;
  final DateTime date;
  final double liters;
  final double cost;
  final int odometer;
  final bool fullTank;
  final String? station;
  final String? notes;

  FuelRecord({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.liters,
    required this.cost,
    required this.odometer,
    this.fullTank = true,
    this.station,
    this.notes,
  });

  double get pricePerLiter => cost / liters;

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'date': date.toIso8601String(),
        'liters': liters,
        'cost': cost,
        'odometer': odometer,
        'fullTank': fullTank ? 1 : 0,
        'station': station,
        'notes': notes,
      };

  factory FuelRecord.fromJson(Map<String, dynamic> json) => FuelRecord(
        id: json['id'] as String,
        vehicleId: json['vehicleId'] as String,
        date: DateTime.parse(json['date'] as String),
        liters: (json['liters'] as num).toDouble(),
        cost: (json['cost'] as num).toDouble(),
        odometer: json['odometer'] as int,
        fullTank: (json['fullTank'] as int) == 1,
        station: json['station'] as String?,
        notes: json['notes'] as String?,
      );
}
