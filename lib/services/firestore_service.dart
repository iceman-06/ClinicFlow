import 'package:clinicflow/models/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get accountsRef =>
      _db.collection('accounts');

  static CollectionReference<Map<String, dynamic>> profilesRef(String accountId) =>
      accountsRef.doc(accountId).collection('profiles');

  static CollectionReference<Map<String, dynamic>> notificationsRef(String accountId) =>
      accountsRef.doc(accountId).collection('notifications');

  static CollectionReference<Map<String, dynamic>> get appointmentsRef =>
      _db.collection('appointments');

  static CollectionReference<Map<String, dynamic>> get bookedSlotsRef =>
      _db.collection('booked_slots');

  static CollectionReference<Map<String, dynamic>> get waitlistRef =>
      _db.collection('waitlist');

  static CollectionReference<Map<String, dynamic>> get openingsRef =>
      _db.collection('openings');

  static String _formatShortDateTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    final timeStr = currentAccount.use24HourTime
        ? '$hh:$mm'
        : '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:$mm ${dt.hour >= 12 ? 'PM' : 'AM'}';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} · $timeStr';
  }

  /// Loads an existing account from `accounts/{uid}` and its `profiles` subcollection,
  /// or creates them in Firestore if this is the user's first login.
  static Future<Account> loadOrCreateAccount(
    User user, {
    String? fallbackName,
    String? fallbackEmail,
    bool isDefaultDemo = false,
    bool seedSampleData = false,
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

        await _seedDefaultAppointments(user.uid, profileId: 'CL-1042', clientName: 'Jamie Chen');
        await _seedDefaultNotifications(user.uid);
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
      if (seedSampleData) {
        await _seedDefaultAppointments(user.uid, profileId: holderProfileId, clientName: resolvedName);
      }
      await _seedDefaultNotifications(user.uid);
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

  static Future<void> _seedDefaultNotifications(String accountId) async {
    final existing = await notificationsRef(accountId).limit(1).get();
    if (existing.docs.isNotEmpty) return;

    await addNotification(
      accountId,
      title: currentAccount.t('medication_reminder'),
      description: currentAccount.t('remember_medication'),
      type: 'reminder',
    );
  }

  static Future<void> _seedDefaultAppointments(
    String accountId, {
    required String profileId,
    required String clientName,
  }) async {
    final existing = await appointmentsRef.where('accountId', isEqualTo: accountId).limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    final todayBase = DateTime(now.year, now.month, now.day);
    final defaults = [
      Appointment(
        id: 'appt_${accountId}_1',
        accountId: accountId,
        profileId: profileId,
        clientName: clientName,
        dateTime: todayBase.add(const Duration(days: 1, hours: 14)),
        duration: const Duration(minutes: 30),
        description: 'Follow-up',
        reason: 'Post-visit check',
        status: 'Upcoming',
      ),
      Appointment(
        id: 'appt_${accountId}_2',
        accountId: accountId,
        profileId: profileId,
        clientName: clientName,
        dateTime: todayBase.add(const Duration(days: 3, hours: 10)),
        duration: const Duration(minutes: 45),
        description: 'Initial consultation',
        reason: 'General wellness assessment',
        status: 'Confirmed',
      ),
    ];

    for (final appt in defaults) {
      await appointmentsRef.doc(appt.id).set(appt.toMap());
      await bookedSlotsRef.doc(appt.id).set({
        'appointmentId': appt.id,
        'dateTime': appt.dateTime.toIso8601String(),
        'duration': appt.duration.inMinutes > 0 ? appt.duration.inMinutes : 60,
      });
    }
  }

  static Future<void> saveAccount(Account account) async {
    if (account.id.isEmpty) return;
    await accountsRef.doc(account.id).set(account.toMap(), SetOptions(merge: true));
  }

  // --- Notifications / Announcements ---

  static Stream<List<Announcement>> streamNotifications(String accountId) {
    if (accountId.isEmpty) return const Stream.empty();
    return notificationsRef(accountId).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => Announcement.fromMap(d.data(), docId: d.id))
          .where((a) => a.isVisible)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  static Future<void> addNotification(
    String accountId, {
    required String title,
    required String description,
    String type = 'info',
  }) async {
    if (accountId.isEmpty) return;
    final docRef = notificationsRef(accountId).doc();
    final announcement = Announcement(
      id: docRef.id,
      title: title,
      description: description,
      type: type,
      isVisible: true,
      createdAt: DateTime.now(),
    );
    await docRef.set(announcement.toMap());
  }

  static Future<void> dismissNotification(String accountId, String notificationId) async {
    if (accountId.isEmpty || notificationId.isEmpty) return;
    await notificationsRef(accountId).doc(notificationId).set({
      'isVisible': false,
    }, SetOptions(merge: true));
  }

  static Future<void> sendClinicAnnouncement({
    required String title,
    required String description,
  }) async {
    final accountsSnap = await accountsRef.get();
    if (accountsSnap.docs.isEmpty && currentAccount.id.isNotEmpty) {
      await addNotification(currentAccount.id, title: title, description: description, type: 'clinic');
      return;
    }
    for (final doc in accountsSnap.docs) {
      await addNotification(doc.id, title: title, description: description, type: 'clinic');
    }
  }

  static Future<void> sendMedicationReminder({
    required String accountId,
    required String patientName,
    required String instructions,
  }) async {
    final targetId = accountId.isNotEmpty ? accountId : currentAccount.id;
    await addNotification(
      targetId,
      title: '${currentAccount.t('medication_reminder')} • $patientName',
      description: instructions,
      type: 'medication',
    );
  }

  // --- Waitlist & Openings ---

  static Stream<List<WaitlistEntry>> streamWaitlistForAccount(String accountId) {
    if (accountId.isEmpty) return const Stream.empty();
    return waitlistRef.where('accountId', isEqualTo: accountId).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => WaitlistEntry.fromMap(d.data(), docId: d.id))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  static Future<String> joinWaitlist(WaitlistEntry entry) async {
    final docRef = waitlistRef.doc();
    entry.id = docRef.id;
    await docRef.set(entry.toMap());
    await addNotification(
      entry.accountId,
      title: currentAccount.t('notif_waitlist_joined_title'),
      description: currentAccount.t(
        'notif_waitlist_joined_desc',
        replacements: [entry.clientName, _formatShortDateTime(entry.preferredDateTime)],
      ),
      type: 'waitlist',
    );
    return docRef.id;
  }

  static Future<void> leaveWaitlist(String entryId) async {
    if (entryId.isEmpty) return;
    await waitlistRef.doc(entryId).delete();
  }

  static Stream<List<ClinicOpening>> streamOpenings() {
    return openingsRef.snapshots().map((snap) {
      final now = DateTime.now();
      final list = snap.docs
          .map((d) => ClinicOpening.fromMap(d.data(), docId: d.id))
          .where((o) => o.dateTime.isAfter(now))
          .toList();
      list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return list;
    });
  }

  static Future<void> claimOpening(String openingId) async {
    if (openingId.isEmpty) return;
    await openingsRef.doc(openingId).delete();
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

  static Stream<List<Appointment>> streamAllAppointments() {
    return appointmentsRef.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => Appointment.fromMap(d.data(), docId: d.id))
          .toList();
      list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return list;
    });
  }

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
      'duration': appointment.duration.inMinutes > 0 ? appointment.duration.inMinutes : 60,
    });

    if (appointment.accountId.isNotEmpty && appointment.profileId.isNotEmpty) {
      final dt = appointment.dateTime;
      final end = appointment.endDateTime;
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

      await addNotification(
        appointment.accountId,
        title: currentAccount.t('notif_booked_title'),
        description: currentAccount.t(
          'notif_booked_desc',
          replacements: [appointment.clientName, _formatShortDateTime(appointment.dateTime)],
        ),
        type: 'appointment',
      );
    }

    return docRef.id;
  }

  static Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    final docSnap = await appointmentsRef.doc(appointmentId).get();
    await appointmentsRef.doc(appointmentId).update({'status': newStatus});
    if (docSnap.exists) {
      final appt = Appointment.fromMap(docSnap.data()!, docId: docSnap.id);
      if (appt.accountId.isNotEmpty) {
        await addNotification(
          appt.accountId,
          title: currentAccount.t('notif_status_title'),
          description: currentAccount.t(
            'notif_status_desc',
            replacements: [appt.clientName, currentAccount.translateStatus(newStatus)],
          ),
          type: 'appointment',
        );
      }
    }
  }

  static Future<void> updateAppointmentDateTime(String appointmentId, DateTime newDateTime) async {
    await appointmentsRef.doc(appointmentId).update({'dateTime': newDateTime.toIso8601String()});
    await bookedSlotsRef.doc(appointmentId).set({
      'appointmentId': appointmentId,
      'dateTime': newDateTime.toIso8601String(),
    }, SetOptions(merge: true));
  }

  static Future<void> cancelAppointment(String appointmentId) async {
    final docSnap = await appointmentsRef.doc(appointmentId).get();
    Appointment? cancelledAppt;
    if (docSnap.exists) {
      cancelledAppt = Appointment.fromMap(docSnap.data()!, docId: docSnap.id);
    }

    await appointmentsRef.doc(appointmentId).delete();
    await bookedSlotsRef.doc(appointmentId).delete();

    if (cancelledAppt != null) {
      if (cancelledAppt.accountId.isNotEmpty) {
        await addNotification(
          cancelledAppt.accountId,
          title: currentAccount.t('notif_cancelled_title'),
          description: currentAccount.t(
            'notif_cancelled_desc',
            replacements: [cancelledAppt.clientName, _formatShortDateTime(cancelledAppt.dateTime)],
          ),
          type: 'appointment',
        );
      }

      if (cancelledAppt.dateTime.isAfter(DateTime.now())) {
        final openingRef = openingsRef.doc();
        final opening = ClinicOpening(
          id: openingRef.id,
          dateTime: cancelledAppt.dateTime,
          durationMinutes: cancelledAppt.duration.inMinutes > 0 ? cancelledAppt.duration.inMinutes : 60,
        );
        await openingRef.set(opening.toMap());

        final waitlistSnap = await waitlistRef.get();
        final notifiedAccounts = <String>{};
        for (final wDoc in waitlistSnap.docs) {
          final entry = WaitlistEntry.fromMap(wDoc.data(), docId: wDoc.id);
          if (entry.accountId.isNotEmpty && !notifiedAccounts.contains(entry.accountId)) {
            notifiedAccounts.add(entry.accountId);
            await addNotification(
              entry.accountId,
              title: currentAccount.t('notif_waitlist_open_title'),
              description: currentAccount.t(
                'notif_waitlist_open_desc',
                replacements: [_formatShortDateTime(cancelledAppt.dateTime)],
              ),
              type: 'waitlist',
            );
          }
        }
      }
    }
  }
}
