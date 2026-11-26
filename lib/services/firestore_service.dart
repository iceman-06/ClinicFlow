import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clinicflow/models/account.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get accountsRef =>
      _db.collection('accounts');

  static CollectionReference<Map<String, dynamic>> profilesRef(String accountId) =>
      accountsRef.doc(accountId).collection('profiles');

  static CollectionReference<Map<String, dynamic>> get appointmentsRef =>
      _db.collection('appointments');

  static CollectionReference<Map<String, dynamic>> get bookedSlotsRef =>
      _db.collection('booked_slots');

  /// Loads an existing account from `accounts/{uid}` and its `profiles` subcollection,
  /// or creates them in Firestore if this is the user's first login.
  static Future<Account> loadOrCreateAccount(
    User user, {
    String? fallbackName,
    String? fallbackEmail,
    bool isDefaultDemo = false,
  }) async {
    final selectedLanguage = currentAccount.language;
    final accountDocRef = accountsRef.doc(user.uid);
    final accountSnap = await accountDocRef.get();

    if (!accountSnap.exists) {
      if (isDefaultDemo) {
        loadDefaultAccount();
        currentAccount.id = user.uid;
        currentAccount.primaryEmail = user.email ?? fallbackEmail ?? 'jamie.chen@clinicflow.app';
        currentAccount.language = selectedLanguage;
        for (final profile in currentAccount.profiles) {
          profile.accountId = user.uid;
        }

        await accountDocRef.set(currentAccount.toMap());
        for (final profile in currentAccount.profiles) {
          await profilesRef(user.uid).doc(profile.id).set(profile.toMap());
        }

        await _seedDefaultAppointments(user.uid);
        return currentAccount;
      }

      final resolvedName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : (fallbackName != null && fallbackName.trim().isNotEmpty
              ? fallbackName.trim()
              : (user.email?.split('@').first ?? 'ClinicFlow User'));
      final resolvedEmail = user.email ?? fallbackEmail ?? '';
      final holderProfileId = 'CL-${user.uid.substring(0, user.uid.length >= 6 ? 6 : user.uid.length).toUpperCase()}';

      final holderProfile = UserProfile(
        id: holderProfileId,
        accountId: user.uid,
        name: resolvedName,
        clientId: holderProfileId,
        dob: DateTime(1992, 1, 1),
        phone: '613-555-0100',
        primaryPhone: '613-555-0100',
        isAccountHolder: true,
        upcomingBooking: 'No upcoming booking',
      );

      final newAccount = Account(
        id: user.uid,
        name: resolvedName,
        primaryEmail: resolvedEmail,
        primaryPhone: '613-555-0100',
        dateOfBirth: DateTime(1992, 1, 1),
        role: UserRole.patient,
        profiles: [holderProfile],
        activeProfileId: holderProfileId,
        language: selectedLanguage,
      );

      await accountDocRef.set(newAccount.toMap());
      await profilesRef(user.uid).doc(holderProfile.id).set(holderProfile.toMap());

      currentAccount = newAccount;
      return currentAccount;
    }

    final data = accountSnap.data()!;
    final profilesSnap = await profilesRef(user.uid).get();
    final loadedProfiles = profilesSnap.docs
        .map((d) => UserProfile.fromMap(d.data(), docId: d.id, parentAccountId: user.uid))
        .toList();

    loadedProfiles.sort((a, b) {
      if (a.isAccountHolder != b.isAccountHolder) {
        return a.isAccountHolder ? -1 : 1;
      }
      return a.name.compareTo(b.name);
    });

    if (loadedProfiles.isEmpty) {
      final holderId = 'CL-${user.uid.substring(0, user.uid.length >= 6 ? 6 : user.uid.length).toUpperCase()}';
      final fallbackProfile = UserProfile(
        id: holderId,
        accountId: user.uid,
        name: data['name'] ?? user.displayName ?? 'ClinicFlow User',
        clientId: holderId,
        dob: DateTime.tryParse(data['dateOfBirth'] ?? '') ?? DateTime(1992, 1, 1),
        phone: data['primaryPhone'] ?? '613-555-0100',
        primaryPhone: data['primaryPhone'] ?? '613-555-0100',
        isAccountHolder: true,
      );
      loadedProfiles.add(fallbackProfile);
      await profilesRef(user.uid).doc(fallbackProfile.id).set(fallbackProfile.toMap());
    }

    final loadedAccount = Account.fromMap(data, profiles: loadedProfiles);
    loadedAccount.id = user.uid;
    if (loadedAccount.primaryEmail.isEmpty && (user.email?.isNotEmpty ?? false)) {
      loadedAccount.primaryEmail = user.email!;
    }
    currentAccount = loadedAccount;
    return currentAccount;
  }

  static Future<void> _seedDefaultAppointments(String accountId) async {
    final existing = await appointmentsRef.where('accountId', isEqualTo: accountId).limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    final todayBase = DateTime(now.year, now.month, now.day);
    final defaults = [
      Appointment(
        id: 'appt_${accountId}_1',
        accountId: accountId,
        profileId: 'CL-1042',
        clientName: 'Jamie Chen',
        dateTime: todayBase.add(const Duration(days: 1, hours: 14, minutes: 30)),
        duration: const Duration(minutes: 30),
        description: 'Follow-up',
        status: 'Upcoming',
      ),
      Appointment(
        id: 'appt_${accountId}_2',
        accountId: accountId,
        profileId: 'CL-1253',
        clientName: 'Daniel Chen',
        dateTime: todayBase.add(const Duration(days: 2, hours: 10, minutes: 0)),
        duration: const Duration(minutes: 45),
        description: 'Initial consultation',
        status: 'Confirmed',
      ),
      Appointment(
        id: 'appt_${accountId}_3',
        accountId: accountId,
        profileId: 'CL-1042',
        clientName: 'Jamie Chen',
        dateTime: todayBase.add(const Duration(days: 14, hours: 11, minutes: 0)),
        duration: const Duration(minutes: 30),
        description: 'Specialist consultation',
        status: 'Confirmed',
      ),
    ];

    for (final appt in defaults) {
      await appointmentsRef.doc(appt.id).set(appt.toMap());
      await bookedSlotsRef.doc(appt.id).set({
        'appointmentId': appt.id,
        'dateTime': appt.dateTime.toIso8601String(),
        'duration': appt.duration.inMinutes,
      });
    }
  }

  static Future<void> saveAccount(Account account) async {
    if (account.id.isEmpty) return;
    await accountsRef.doc(account.id).set(account.toMap(), SetOptions(merge: true));
  }

  // --- Profiles (subcollection under accounts/{accountId}/profiles) ---

  static Stream<List<UserProfile>> streamProfiles(String accountId) {
    return profilesRef(accountId).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => UserProfile.fromMap(d.data(), docId: d.id, parentAccountId: accountId))
          .toList();
      list.sort((a, b) {
        if (a.isAccountHolder != b.isAccountHolder) {
          return a.isAccountHolder ? -1 : 1;
        }
        return a.name.compareTo(b.name);
      });
      if (accountId == currentAccount.id && list.isNotEmpty) {
        currentAccount.profiles = list;
        if (!list.any((p) => p.id == currentAccount.activeProfileId)) {
          currentAccount.activeProfileId = list.first.id;
        }
      }
      return list;
    });
  }

  static Stream<List<UserProfile>> streamAllProfilesForStaff() {
    return _db.collectionGroup('profiles').snapshots().map((snap) {
      final list = snap.docs.map((d) {
        final parentAccountId = d.reference.parent.parent?.id ?? '';
        return UserProfile.fromMap(d.data(), docId: d.id, parentAccountId: parentAccountId);
      }).toList();
      list.sort((a, b) => a.name.compareTo(b.name));
      return list;
    });
  }

  static Future<void> saveProfile(String accountId, UserProfile profile) async {
    if (accountId.isEmpty) return;
    profile.accountId = accountId;
    await profilesRef(accountId).doc(profile.id).set(profile.toMap(), SetOptions(merge: true));
  }

  static Future<void> deleteProfile(String accountId, String profileId) async {
    if (accountId.isEmpty) return;
    await profilesRef(accountId).doc(profileId).delete();
  }

  // --- Appointments (top-level collection, separate from accounts) ---

  /// Client view: only appointments booked by [accountId].
  static Stream<List<Appointment>> streamAccountAppointments(String accountId) {
    return appointmentsRef
        .where('accountId', isEqualTo: accountId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => Appointment.fromMap(d.data(), docId: d.id))
          .toList();
      list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return list;
    });
  }

  /// Staff view: all appointments across all accounts.
  static Stream<List<Appointment>> streamAllAppointments() {
    return appointmentsRef.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => Appointment.fromMap(d.data(), docId: d.id))
          .toList();
      list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return list;
    });
  }

  /// Public-to-signed-in-users taken time slots (no private patient details).
  static Stream<List<BookedSlot>> streamBookedSlots() {
    return bookedSlotsRef.snapshots().map((snap) {
      return snap.docs
          .map((d) => BookedSlot.fromMap(d.data(), docId: d.id))
          .toList();
    });
  }

  static Future<String> createAppointment(Appointment appointment) async {
    final docRef = appointment.id.isNotEmpty
        ? appointmentsRef.doc(appointment.id)
        : appointmentsRef.doc();
    appointment.id = docRef.id;
    await docRef.set(appointment.toMap());
    await bookedSlotsRef.doc(docRef.id).set({
      'appointmentId': docRef.id,
      'dateTime': appointment.dateTime.toIso8601String(),
      'duration': appointment.duration.inMinutes,
    });

    if (appointment.accountId.isNotEmpty && appointment.profileId.isNotEmpty) {
      final dt = appointment.dateTime;
      final end = dt.add(appointment.duration);
      final startStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final summary = '${weekdays[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} · $startStr–$endStr';
      final subInfo = '${appointment.description} · ${appointment.status}';

      await profilesRef(appointment.accountId).doc(appointment.profileId).set({
        'upcomingBooking': summary,
        'bookingSubInfo': subInfo,
      }, SetOptions(merge: true));
    }

    return docRef.id;
  }

  static Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    await appointmentsRef.doc(appointmentId).update({'status': newStatus});
  }

  static Future<void> updateAppointmentDateTime(String appointmentId, DateTime newDateTime) async {
    await appointmentsRef.doc(appointmentId).update({'dateTime': newDateTime.toIso8601String()});
    await bookedSlotsRef.doc(appointmentId).set({
      'appointmentId': appointmentId,
      'dateTime': newDateTime.toIso8601String(),
    }, SetOptions(merge: true));
  }

  static Future<void> cancelAppointment(String appointmentId) async {
    await appointmentsRef.doc(appointmentId).delete();
    await bookedSlotsRef.doc(appointmentId).delete();
  }
}
