import 'package:flutter/material.dart';

enum ServiceType {
  maintenance,
  repair,
  inspection,
  oil,
  tires,
  brakes,
  battery,
  filters,
  other;

  String get displayName {
    switch (this) {
      case ServiceType.maintenance:
        return 'Maintenance';
      case ServiceType.repair:
        return 'Repair';
      case ServiceType.inspection:
        return 'Inspection';
      case ServiceType.oil:
        return 'Oil Change';
      case ServiceType.tires:
        return 'Tires';
      case ServiceType.brakes:
        return 'Brakes';
      case ServiceType.battery:
        return 'Battery';
      case ServiceType.filters:
        return 'Filters';
      case ServiceType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceType.maintenance:
        return Icons.build;
      case ServiceType.repair:
        return Icons.handyman;
      case ServiceType.inspection:
        return Icons.search;
      case ServiceType.oil:
        return Icons.opacity;
      case ServiceType.tires:
        return Icons.tire_repair;
      case ServiceType.brakes:
        return Icons.do_not_disturb_on;
      case ServiceType.battery:
        return Icons.battery_charging_full;
      case ServiceType.filters:
        return Icons.filter_alt;
      case ServiceType.other:
        return Icons.more_horiz;
    }
  }
}
