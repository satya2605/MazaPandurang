/// Model for a local service (medical, water, food, etc.)
/// Owned by: Gauri — Local Citizen Module
///
/// When the real backend is ready, replace MockCitizenServiceData
/// with an ApiCitizenServiceRepository. This model stays the same.
library citizen_service;

/// The category of a service (matches SRS-defined types).
enum ServiceCategory {
  medical,
  food,
  water,
  toilet,
  nightHalt,
  parking,
  police,
  hospital,
  pharmacy,
  helpCentre,
  other;

  String get label {
    switch (this) {
      case ServiceCategory.medical:
        return 'Medical';
      case ServiceCategory.food:
        return 'Food / Annachhatra';
      case ServiceCategory.water:
        return 'Water';
      case ServiceCategory.toilet:
        return 'Toilets';
      case ServiceCategory.nightHalt:
        return 'Night Halt';
      case ServiceCategory.parking:
        return 'Parking';
      case ServiceCategory.police:
        return 'Police';
      case ServiceCategory.hospital:
        return 'Hospital';
      case ServiceCategory.pharmacy:
        return 'Pharmacy';
      case ServiceCategory.helpCentre:
        return 'Help Centre';
      case ServiceCategory.other:
        return 'Other';
    }
  }

  String get marathiLabel {
    switch (this) {
      case ServiceCategory.medical:
        return 'वैद्यकीय';
      case ServiceCategory.food:
        return 'अन्नछत्र';
      case ServiceCategory.water:
        return 'पाणी';
      case ServiceCategory.toilet:
        return 'शौचालय';
      case ServiceCategory.nightHalt:
        return 'रात्र मुक्काम';
      case ServiceCategory.parking:
        return 'पार्किंग';
      case ServiceCategory.police:
        return 'पोलीस';
      case ServiceCategory.hospital:
        return 'रुग्णालय';
      case ServiceCategory.pharmacy:
        return 'औषधालय';
      case ServiceCategory.helpCentre:
        return 'मदत केंद्र';
      case ServiceCategory.other:
        return 'इतर';
    }
  }
}

/// Availability status of a service (Citizen is READ-ONLY).
enum ServiceStatus {
  open,
  closed,
  full,
  available,
  limited,
  finished,
  unknown;

  String get label {
    switch (this) {
      case ServiceStatus.open:
        return 'OPEN';
      case ServiceStatus.closed:
        return 'CLOSED';
      case ServiceStatus.full:
        return 'FULL';
      case ServiceStatus.available:
        return 'AVAILABLE';
      case ServiceStatus.limited:
        return 'LIMITED';
      case ServiceStatus.finished:
        return 'FINISHED';
      case ServiceStatus.unknown:
        return 'UNKNOWN';
    }
  }
}

/// A single service visible to the Local Citizen.
class CitizenService {
  final String id;
  final String name;
  final ServiceCategory category;
  final ServiceStatus status;
  final double distanceMetres;
  final String address;
  final String? phone;
  final String? description;
  final double latitude;
  final double longitude;
  final DateTime lastUpdatedAt;

  const CitizenService({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.distanceMetres,
    required this.address,
    this.phone,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.lastUpdatedAt,
  });

  String get distanceLabel {
    if (distanceMetres < 1000) {
      return '${distanceMetres.toStringAsFixed(0)} m away';
    }
    return '${(distanceMetres / 1000).toStringAsFixed(1)} km away';
  }

  String get lastUpdatedLabel {
    final diff = DateTime.now().difference(lastUpdatedAt);
    if (diff.inMinutes < 1) return 'Just updated';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours} h ago';
    return 'Updated ${diff.inDays} days ago';
  }
}

/// MOCK DATA — for development only (Pandharpur area coordinates).
/// Replace with ApiCitizenServiceRepository when backend is ready.
class MockCitizenServiceData {
  static final List<CitizenService> services = [
    CitizenService(
      id: 'svc-001',
      name: 'Pandharpur Medical Camp',
      category: ServiceCategory.medical,
      status: ServiceStatus.open,
      distanceMetres: 320,
      address: 'Near Vitthal Mandir Gate, Pandharpur',
      phone: '02166-222001',
      description:
          'Free medical checkup, first aid, and medicines for pilgrims and citizens. Operated by District Health Department.',
      latitude: 17.6733,
      longitude: 75.3278,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    CitizenService(
      id: 'svc-002',
      name: 'Annachhatra Seva Trust',
      category: ServiceCategory.food,
      status: ServiceStatus.available,
      distanceMetres: 480,
      address: 'Bhima Ghat Road, Pandharpur',
      phone: '9876543210',
      description: 'Free meals 7 AM – 10 PM. Capacity 5000. Pure vegetarian Wari food.',
      latitude: 17.6745,
      longitude: 75.3265,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    CitizenService(
      id: 'svc-003',
      name: 'Jal Seva Water Station',
      category: ServiceCategory.water,
      status: ServiceStatus.available,
      distanceMetres: 150,
      address: 'Chandrabhaga Bridge, Pandharpur',
      phone: null,
      description: 'Clean drinking water 24x7. Municipal corporation managed.',
      latitude: 17.6720,
      longitude: 75.3290,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
    CitizenService(
      id: 'svc-004',
      name: 'Municipal Toilet Complex',
      category: ServiceCategory.toilet,
      status: ServiceStatus.open,
      distanceMetres: 250,
      address: 'Near ST Stand, Pandharpur',
      phone: null,
      description: 'Public toilets. Separate sections for men and women.',
      latitude: 17.6712,
      longitude: 75.3300,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    CitizenService(
      id: 'svc-005',
      name: 'Wari Night Halt – Sector 3',
      category: ServiceCategory.nightHalt,
      status: ServiceStatus.limited,
      distanceMetres: 720,
      address: 'Pandharpur School Ground, Sector 3',
      phone: '02166-223456',
      description:
          'Community night halt. Mats, water, and basic sanitation provided. Limited space remaining.',
      latitude: 17.6760,
      longitude: 75.3250,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    CitizenService(
      id: 'svc-006',
      name: 'District Hospital Pandharpur',
      category: ServiceCategory.hospital,
      status: ServiceStatus.open,
      distanceMetres: 1200,
      address: 'Hospital Road, Pandharpur',
      phone: '02166-222500',
      description: 'Full government hospital. OPD 8 AM – 8 PM. Emergency 24x7.',
      latitude: 17.6700,
      longitude: 75.3320,
      lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    CitizenService(
      id: 'svc-007',
      name: 'Pandharpur Police Help Desk',
      category: ServiceCategory.police,
      status: ServiceStatus.open,
      distanceMetres: 400,
      address: 'Main Square, Pandharpur',
      phone: '100',
      description:
          'Police assistance for lost items, safety queries, and emergency help during Wari.',
      latitude: 17.6730,
      longitude: 75.3275,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    CitizenService(
      id: 'svc-008',
      name: 'Sai Pharma – 24hr Pharmacy',
      category: ServiceCategory.pharmacy,
      status: ServiceStatus.open,
      distanceMetres: 560,
      address: 'Market Chowk, Pandharpur',
      phone: '9823456780',
      description: '24-hour pharmacy. Prescription and OTC medicines available.',
      latitude: 17.6740,
      longitude: 75.3260,
      lastUpdatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];
}
