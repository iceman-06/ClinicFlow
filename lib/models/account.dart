import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/models/palette.dart';
import 'package:clinicflow/models/translation.dart';

enum UserRole { patient, staff }

class UserProfile {
  String id;
  String name;
  String clientId;
  DateTime dob;
  String phone;
  String primaryPhone;
  String notes;
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
    required this.primaryPhone,
    this.notes = "",
    this.isAccountHolder = false,
    this.upcomingBooking = "No upcoming booking",
    this.bookingSubInfo = "",
    this.lastVisit = "",
  }) {
    UserProfile.onCreated?.call(this);
  }

  static void Function(UserProfile)? onCreated;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'clientId': clientId,
      'dob': dob.toIso8601String(),
      'phone': phone,
      'primaryPhone': primaryPhone,
      'notes': notes,
      'isAccountHolder': isAccountHolder,
      'upcomingBooking': upcomingBooking,
      'bookingSubInfo': bookingSubInfo,
      'lastVisit': lastVisit,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      clientId: map['clientId'] ?? '',
      dob: DateTime.parse(map['dob'] ?? DateTime.now().toIso8601String()),
      phone: map['phone'] ?? '',
      primaryPhone: map['primaryPhone'] ?? '',
      notes: map['notes'] ?? '',
      isAccountHolder: map['isAccountHolder'] ?? false,
      upcomingBooking: map['upcomingBooking'] ?? '',
      bookingSubInfo: map['bookingSubInfo'] ?? '',
      lastVisit: map['lastVisit'] ?? '',
    );
  }

  static UserProfile? retrieve(String profileId, List<UserProfile> list) {
    try {
      return list.firstWhere((p) => p.id == profileId);
    } catch (_) {
      return null;
    }
  }

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

class Appointment {
  String id;
  String clientName;
  DateTime dateTime;
  Duration duration;
  String description;
  String status;

  Appointment({
    required this.id,
    required this.clientName,
    required this.dateTime,
    required this.duration,
    required this.description,
    required this.status,
  }) {
    Appointment.onCreated?.call(this);
  }

  static void Function(Appointment)? onCreated;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientName': clientName,
      'dateTime': dateTime.toIso8601String(),
      'duration': duration.inMinutes,
      'description': description,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      clientName: map['clientName'] ?? '',
      dateTime: DateTime.parse(map['dateTime'] ?? DateTime.now().toIso8601String()),
      duration: Duration(minutes: map['duration'] ?? 30),
      description: map['description'] ?? '',
      status: map['status'] ?? '',
    );
  }

  static Appointment? retrieve(String id, List<Appointment> list) {
    try {
      return list.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  static Map<String, int> getStatusCounts(List<Appointment> list) {
    final counts = <String, int>{'Done': 0, 'In progress': 0, 'Checked in': 0, 'No-show': 0, 'Expected': 0};
    for (var a in list) {
      counts[a.status] = (counts[a.status] ?? 0) + 1;
    }
    return counts;
  }
}

class Announcement {
  String id;
  String title;
  String description;
  bool isVisible;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    this.isVisible = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isVisible': isVisible,
    };
  }

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isVisible: map['isVisible'] ?? true,
    );
  }

  static List<Announcement> retrieveAnnouncements() {
    return [
      Announcement(
        id: 'ann-1',
        title: "Appointment in 20 minutes",
        description: "Jamie Chen • Today, 14:30-15:00",
      ),
      Announcement(
        id: 'ann-2',
        title: "Medication reminder",
        description: "Remember to follow your prescribed schedule",
      ),
    ];
  }
}

class Account {
  String id;
  String name;
  String primaryEmail;
  String primaryPhone;
  DateTime dateOfBirth;
  UserRole role;

  List<UserProfile> profiles;
  String activeProfileId;

  String theme;
  bool emailReminders;
  bool smsReminders;
  bool virtualCheckInEnabled;
  bool staffNotifications;
  bool automatedCheckInPrompts;
  String privacyStatusText;
  AppLanguage language;

  Account({
    required this.id,
    required this.name,
    required this.primaryEmail,
    required this.primaryPhone,
    required this.dateOfBirth,
    this.role = UserRole.patient,
    required this.profiles,
    required this.activeProfileId,
    this.theme = "Coastal",
    this.emailReminders = true,
    this.smsReminders = true,
    this.virtualCheckInEnabled = true,
    this.staffNotifications = true,
    this.automatedCheckInPrompts = true,
    this.privacyStatusText = "Review",
    this.language = AppLanguage.english,
  }) {
    Account.onCreated?.call(this);
  }

  static void Function(Account)? onCreated;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'primaryEmail': primaryEmail,
      'primaryPhone': primaryPhone,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'role': role.name,
      'profiles': profiles.map((p) => p.toMap()).toList(),
      'activeProfileId': activeProfileId,
      'theme': theme,
      'emailReminders': emailReminders,
      'smsReminders': smsReminders,
      'virtualCheckInEnabled': virtualCheckInEnabled,
      'staffNotifications': staffNotifications,
      'automatedCheckInPrompts': automatedCheckInPrompts,
      'privacyStatusText': privacyStatusText,
      'language': language.name,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      primaryEmail: map['primaryEmail'] ?? '',
      primaryPhone: map['primaryPhone'] ?? '',
      dateOfBirth: DateTime.parse(map['dateOfBirth'] ?? DateTime.now().toIso8601String()),
      role: map['role'] == 'staff' ? UserRole.staff : UserRole.patient,
      profiles: (map['profiles'] as List? ?? []).map((p) => UserProfile.fromMap(p)).toList(),
      activeProfileId: map['activeProfileId'] ?? '',
      theme: map['theme'] ?? 'Coastal',
      emailReminders: map['emailReminders'] ?? true,
      smsReminders: map['smsReminders'] ?? true,
      virtualCheckInEnabled: map['virtualCheckInEnabled'] ?? true,
      staffNotifications: map['staffNotifications'] ?? true,
      automatedCheckInPrompts: map['automatedCheckInPrompts'] ?? true,
      privacyStatusText: map['privacyStatusText'] ?? 'Review',
      language: map['language'] == 'french' ? AppLanguage.french : AppLanguage.english,
    );
  }

  static Account? retrieve(String accountId, List<Account> list) {
    try {
      return list.firstWhere((a) => a.id == accountId);
    } catch (_) {
      return null;
    }
  }

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

  void toggleLanguage() {
    language = language == AppLanguage.english ? AppLanguage.french : AppLanguage.english;
  }

  String t(String key) => AppLocalizations.get(language, key);
}

late Account currentAccount;

void loadDefaultAccount() {
  currentAccount = Account(
    id: 'CL-1042',
    name: 'Jamie Chen',
    primaryEmail: 'jamie.chen@example.com',
    primaryPhone: '613-555-0142',
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
        phone: '613-555-0142',
        primaryPhone: '613-555-0142',
        notes: 'Patient exhibits stable post-operative recovery.',
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
        phone: '613-555-0186',
        primaryPhone: '613-555-0142',
        notes: 'Annual check-up completed successfully.',
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
        phone: '613-555-0253',
        primaryPhone: '613-555-0142',
        notes: 'Scheduled for initial consultation.',
        isAccountHolder: false,
        upcomingBooking: 'Tuesday, 10 Nov · 10:00–10:45',
        bookingSubInfo: 'Initial consultation · Confirmed',
        lastVisit: '15 Sep 2026',
      ),
    ],
  );
}