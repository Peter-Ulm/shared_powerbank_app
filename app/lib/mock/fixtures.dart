import '../domain/models/cabinet.dart';

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
