import '../domain/models/cabinet.dart';
import '../domain/models/rental.dart';

const kUnitPriceTzs = 1000;

final mockCabinets = <Cabinet>[
  const Cabinet(
    id: 'CAB001', label: 'Mlimani City - Gate', banksAvailable: 6,
    freeSlots: 10, online: true, lat: -6.770, lng: 39.241,
    distanceMeters: 120, unitPriceTzs: kUnitPriceTzs,
  ),
  const Cabinet(
    id: 'CAB002', label: 'Posta - CBD', banksAvailable: 2,
    freeSlots: 3, online: true, lat: -6.816, lng: 39.289,
    distanceMeters: 640, unitPriceTzs: kUnitPriceTzs,
  ),
  const Cabinet(
    id: 'CAB003', label: 'Mwenge', banksAvailable: 0,
    freeSlots: 0, online: false, lat: -6.772, lng: 39.226,
    distanceMeters: 1500, unitPriceTzs: kUnitPriceTzs,
  ),
];

final mockHistoryRentals = <Rental>[
  Rental(
    id: 'H1', powerbankId: 'PB-H1', status: RentalStatus.completed,
    startedAt: DateTime(2026, 6, 10, 9), dueAt: DateTime(2026, 6, 10, 14),
    returnedAt: DateTime(2026, 6, 10, 11, 30), cabinetOutId: 'CAB001',
  ),
  Rental(
    id: 'H2', powerbankId: 'PB-H2', status: RentalStatus.completed,
    startedAt: DateTime(2026, 6, 8, 18), dueAt: DateTime(2026, 6, 8, 23),
    returnedAt: DateTime(2026, 6, 8, 22), cabinetOutId: 'CAB002', overageTzs: 0,
  ),
];
