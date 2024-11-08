import 'package:norimoto/domain/models/service_type.dart';

class ServiceRecord {
  final String id;
  final String vehicleId;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? reminderDate;
  final double cost;
  final int mileage;
  final String serviceProvider;
  final ServiceType type;
  final List<String> receipts;
  final bool isScheduled;
  final bool isRecurring;
  final int? recurringMonths;
  final int? recurringKilometers;

  ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.description,
    required this.date,
    this.reminderDate,
    required this.cost,
    required this.mileage,
    required this.serviceProvider,
    required this.type,
    this.receipts = const [],
    this.isScheduled = false,
    this.isRecurring = false,
    this.recurringMonths,
    this.recurringKilometers,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'reminderDate': reminderDate?.toIso8601String(),
        'cost': cost,
        'mileage': mileage,
        'serviceProvider': serviceProvider,
        'type': type.name,
        'receipts': receipts,
        'isScheduled': isScheduled ? 1 : 0,
        'isRecurring': isRecurring ? 1 : 0,
        'recurringMonths': recurringMonths,
        'recurringKilometers': recurringKilometers,
      };

  factory ServiceRecord.fromJson(Map<String, dynamic> json) => ServiceRecord(
        id: json['id'] as String,
        vehicleId: json['vehicleId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        date: DateTime.parse(json['date'] as String),
        reminderDate: json['reminderDate'] == null
            ? null
            : DateTime.parse(json['reminderDate'] as String),
        cost: (json['cost'] as num).toDouble(),
        mileage: json['mileage'] as int,
        serviceProvider: json['serviceProvider'] as String,
        type: ServiceType.values.byName(json['type'] as String),
        receipts: List<String>.from(json['receipts'] as List),
        isScheduled: (json['isScheduled'] as int) == 1,
        isRecurring: (json['isRecurring'] as int) == 1,
        recurringMonths: json['recurringMonths'] as int?,
        recurringKilometers: json['recurringKilometers'] as int?,
      );

  ServiceRecord copyWith({
    String? id,
    String? vehicleId,
    String? title,
    String? description,
    DateTime? date,
    DateTime? reminderDate,
    double? cost,
    int? mileage,
    String? serviceProvider,
    ServiceType? type,
    List<String>? receipts,
    bool? isScheduled,
    bool? isRecurring,
    int? recurringMonths,
    int? recurringKilometers,
  }) =>
      ServiceRecord(
        id: id ?? this.id,
        vehicleId: vehicleId ?? this.vehicleId,
        title: title ?? this.title,
        description: description ?? this.description,
        date: date ?? this.date,
        reminderDate: reminderDate ?? this.reminderDate,
        cost: cost ?? this.cost,
        mileage: mileage ?? this.mileage,
        serviceProvider: serviceProvider ?? this.serviceProvider,
        type: type ?? this.type,
        receipts: receipts ?? this.receipts,
        isScheduled: isScheduled ?? this.isScheduled,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringMonths: recurringMonths ?? this.recurringMonths,
        recurringKilometers: recurringKilometers ?? this.recurringKilometers,
      );
}
