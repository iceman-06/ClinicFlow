import 'package:clinicflow/models/palette.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

class ClinicSearchArea {
  final String label;
  final LatLng center;
  final double radiusKm;

  const ClinicSearchArea({
    required this.label,
    required this.center,
    this.radiusKm = 5.0,
  });

  ClinicSearchArea copyWith({
    String? label,
    LatLng? center,
    double? radiusKm,
  }) {
    return ClinicSearchArea(
      label: label ?? this.label,
      center: center ?? this.center,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }
}

class Clinic {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final String hoursStatus;
  final String doctorName;
  final String address;
  final String phone;
  final String email;
  final LatLng location;

  const Clinic({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.hoursStatus,
    required this.doctorName,
    required this.address,
    required this.phone,
    required this.email,
    required this.location,
  });

  double distanceKmFrom(LatLng origin) {
    const distance = Distance();
    return distance.as(LengthUnit.Kilometer, origin, location);
  }
}

const List<ClinicSearchArea> presetSearchAreas = [
  ClinicSearchArea(
    label: 'Centretown, Ottawa',
    center: LatLng(45.4145, -75.6950),
    radiusKm: 5.0,
  ),
ClinicSearchArea(
  label: 'The Glebe, Ottawa',
  center: LatLng(45.3985, -75.6885),
  radiusKm: 5.0,
),
ClinicSearchArea(
  label: 'ByWard Market, Ottawa',
  center: LatLng(45.4285, -75.6925),
  radiusKm: 5.0,
),
ClinicSearchArea(
  label: 'Westboro, Ottawa',
  center: LatLng(45.3945, -75.7525),
  radiusKm: 5.0,
),
];

const List<Clinic> sampleClinics = [
  Clinic(
    id: 'cl-1',
    name: 'Bank Street Family Clinic',
    specialty: 'General practice',
    rating: 4.8,
    reviewCount: 124,
    hoursStatus: 'Open · Closes 18:00',
    doctorName: 'Dr Maya Patel - Lead GP',
    address: '240 Bank Street, Ottawa, ON',
    phone: '613-555-0148',
    email: 'hello@bankstreetclinic.example',
    location: LatLng(45.4162, -75.6962),
  ),
Clinic(
  id: 'cl-2',
  name: 'Elgin Health Centre',
  specialty: 'Physiotherapy',
  rating: 4.6,
  reviewCount: 89,
  hoursStatus: 'Open · Closes 19:00',
  doctorName: 'Dr Liam O\'Connor - Lead PT',
  address: '150 Elgin Street, Ottawa, ON',
  phone: '613-555-0192',
  email: 'care@elginhealth.example',
  location: LatLng(45.4198, -75.6915),
),
Clinic(
  id: 'cl-3',
  name: 'Glebe Dental Studio',
  specialty: 'Dental',
  rating: 4.9,
  reviewCount: 203,
  hoursStatus: 'Open · Closes 17:30',
  doctorName: 'Dr Hannah Kim - DDS',
  address: '785 Bank Street, Ottawa, ON',
  phone: '613-555-0174',
  email: 'desk@glebedental.example',
  location: LatLng(45.3992, -75.6894),
),
Clinic(
  id: 'cl-4',
  name: 'Rideau Paediatric Care',
  specialty: 'Paediatrics',
  rating: 4.7,
  reviewCount: 76,
  hoursStatus: 'Open · Closes 18:30',
  doctorName: 'Dr Samira Haddad - MD',
  address: '95 Rideau Street, Ottawa, ON',
  phone: '613-555-0131',
  email: 'info@rideaupaeds.example',
  location: LatLng(45.4265, -75.6910),
),
Clinic(
  id: 'cl-5',
  name: 'Somerset Dermatology',
  specialty: 'Dermatology',
  rating: 4.5,
  reviewCount: 64,
  hoursStatus: 'Open · Closes 17:00',
  doctorName: 'Dr Noah Tremblay - MD',
  address: '310 Somerset Street W, Ottawa, ON',
  phone: '613-555-0166',
  email: 'appointments@somersetderm.example',
  location: LatLng(45.4112, -75.7020),
),
Clinic(
  id: 'cl-6',
  name: 'Richmond Road Clinic',
  specialty: 'General practice',
  rating: 4.4,
  reviewCount: 52,
  hoursStatus: 'Open · Closes 18:00',
  doctorName: 'Dr Claire Bouchard - MD',
  address: '3420 Richmond Road, Ottawa, ON',
  phone: '613-555-0188',
  email: 'contact@richmondclinic.example',
  location: LatLng(45.3625, -75.7985),
),
];

/// Helper to build a `CircleMarker` list for `flutter_map` matching the radius in km.
List<CircleMarker> buildRadiusCircles({
  required LatLng center,
  required double radiusKm,
  required ColorPalette palette,
}) {
  return [
    CircleMarker(
      point: center,
      radius: radiusKm * 1000,
      useRadiusInMeter: true,
      color: Colors.blue.withAlpha(75),
      borderColor: Colors.blue.withAlpha(210),
      borderStrokeWidth: 2.5,
    ),
  ];
}
