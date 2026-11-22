import 'package:clinicflow/models/palette.dart';

enum UserRole { patient, staff }

class UserProfile {
  String id;
  String name;
  String clientId;
  DateTime dob;
  String phone;
  bool isAccountHolder;
  String upcomingBooking;
  String bookingSubInfo;
  String lastVisit;

  UserProfile({
    required this.id,
    required this.name,
    required this.clientId,
    required this.dob,
    required this.phone,
    this.isAccountHolder = false,
    this.upcomingBooking = "No upcoming booking",
    this.bookingSubInfo = "",
    this.lastVisit = "",
  });

  String get formattedDob {
    return "DOB ${dob.day} ${_getMonthName(dob.month)} ${dob.year}";
  }

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}

class Account {
  String id;
  String name;
  String email;
  String phone;
  DateTime dateOfBirth;
  UserRole role;

  List<UserProfile> profiles;
  String activeProfileId;

  String theme;
  bool emailReminders;
  bool smsReminders;
  bool virtualCheckInEnabled;
  String privacyStatusText;

  Account({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    this.role = UserRole.patient,
    required this.profiles,
    required this.activeProfileId,
    this.theme = "Coastal",
    this.emailReminders = true,
    this.smsReminders = true,
    this.virtualCheckInEnabled = true,
    this.privacyStatusText = "Review",
  });

  bool get isStaff => role == UserRole.staff;

  ColorPalette get palette => AppPalettes.fromName(theme);

  UserProfile get activeProfile {
    return profiles.firstWhere(
      (p) => p.id == activeProfileId,
      orElse: () => profiles.first,
    );
  }

  String get initials {
    final active = activeProfile;
    final parts = active.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return active.name.isNotEmpty ? active.name[0].toUpperCase() : '?';
  }

  void toggleRole() {
    role = isStaff ? UserRole.patient : UserRole.staff;
  }
}

final Account currentAccount = Account(
  id: 'CL-1042',
  name: 'Jamie Chen',
  email: 'jamie.chen@example.com',
  phone: '07700 900142',
  dateOfBirth: DateTime(1992, 3, 12),
  role: UserRole.patient,
  activeProfileId: 'CL-1042',
  privacyStatusText: "Review",
  profiles: [
    UserProfile(
      id: 'CL-1042',
      name: 'Jamie Chen',
      clientId: 'CL-1042',
      dob: DateTime(1992, 3, 12),
      phone: '07700 900142',
      isAccountHolder: true,
      upcomingBooking: 'Monday, 9 Nov · 14:30–15:00',
      bookingSubInfo: 'Follow-up · Upcoming',
      lastVisit: '26 Oct 2026',
    ),
    UserProfile(
      id: 'CL-1186',
      name: 'Olivia Chen',
      clientId: 'CL-1186',
      dob: DateTime(1985, 8, 24),
      phone: '07700 900186',
      isAccountHolder: false,
      upcomingBooking: 'No upcoming booking',
      bookingSubInfo: 'Last visit: Today at 12:00 · Done',
      lastVisit: 'Today at 12:00',
    ),
    UserProfile(
      id: 'CL-1253',
      name: 'Daniel Chen',
      clientId: 'CL-1253',
      dob: DateTime(1978, 2, 6),
      phone: '07700 900253',
      isAccountHolder: false,
      upcomingBooking: 'Tuesday, 10 Nov · 10:00–10:45',
      bookingSubInfo: 'Initial consultation · Confirmed',
      lastVisit: '15 Sep 2026',
    ),
  ],
);