import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/services/firestore_service.dart';
import 'package:clinicflow/pages/client/clinic_search_page.dart';

class UpcomingAppointment extends StatelessWidget {
  final Appointment appointment;

  const UpcomingAppointment({
    super.key,
    required this.appointment,
  });

  void _showAppointmentPopup(BuildContext context) {
    final date = appointment.dateTime;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: currentAccount.t('appointment_details'), weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BetterText(text: currentAccount.t('patient_label', replacements: [appointment.clientName]), weight: 600, size: 15.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 8.0),
            BetterText(text: currentAccount.t('date_label', replacements: ["${getWeekDay(dateTime: date)}, ${getMonth(dateTime: date)} ${getDay(dateTime: date)} ${date.year}"]), size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: currentAccount.t('time_label', replacements: ["${formatDateTimeTime(date)} (${appointment.formattedDuration})"]), size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: currentAccount.t('description_label', replacements: [currentAccount.translateAppointmentType(appointment.description)]), size: 14.0, colour: currentAccount.palette.textPrimary),
            if (appointment.reason.isNotEmpty) ...[
              const SizedBox(height: 6.0),
              BetterText(text: currentAccount.t('reason_label', replacements: [appointment.reason]), size: 14.0, colour: currentAccount.palette.textPrimary),
            ],
            const SizedBox(height: 6.0),
            BetterText(text: currentAccount.t('status_label', replacements: [currentAccount.translateStatus(appointment.status)]), size: 14.0, colour: currentAccount.palette.primary),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirestoreService.cancelAppointment(appointment.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(currentAccount.t('appointment_cancelled_success'))),
              );
            },
            child: BetterText(text: currentAccount.t('cancel_appointment'), colour: Colors.red, weight: 600),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: BetterText(text: currentAccount.t('close'), colour: currentAccount.palette.primary, weight: 600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = appointment.dateTime;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: IntrinsicHeight(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BetterText(
                        text: formatDateTimeTime(date),
                        colour: currentAccount.palette.textPrimary,
                      ),
                      BetterText(
                        text: appointment.isDurationUnknown
                            ? currentAccount.t('unknown_length')
                            : formatDateTimeTime(appointment.endDateTime),
                        size: 11.0,
                        colour: currentAccount.palette.textSecondary,
                      ),
                    ],
                  ),
                  const VerticalDivider(
                    thickness: 1.5,
                    width: 30.0,
                    color: Colors.transparent,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BetterText(text: appointment.clientName, colour: currentAccount.palette.textPrimary),
                      BetterText(
                        text:
                            "${getWeekDay(truncate: true, dateTime: date)}, ${getDay(dateTime: date)} ${getMonth(truncate: true, dateTime: date)} • ${currentAccount.translateAppointmentType(appointment.description)} • ${appointment.formattedDuration}",
                        size: 11.0,
                        colour: currentAccount.palette.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => _showAppointmentPopup(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: BetterText(
                        text: currentAccount.translateStatus(appointment.status),
                        size: 12.0,
                        colour: currentAccount.palette.textPrimary,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right, color: currentAccount.palette.textPrimary),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _computeNextAvailableOpening(List<ClinicOpening> openings, List<BookedSlot> bookedSlots) {
    if (openings.isNotEmpty) {
      return openings.first.dateTime;
    }
    final now = DateTime.now();
    for (int dayOffset = 1; dayOffset <= 14; dayOffset++) {
      final day = DateTime(now.year, now.month, now.day + dayOffset);
      for (int hour = 9; hour <= 17; hour++) {
        final candidate = DateTime(day.year, day.month, day.day, hour, 0);
        final taken = bookedSlots.any((s) => s.overlaps(candidate, const Duration(minutes: 60)));
        if (!taken) {
          return candidate;
        }
      }
    }
    return DateTime(now.year, now.month, now.day + 1, 9, 0);
  }

  void _showCodePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: currentAccount.t('check_in_pass'), weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                color: currentAccount.palette.secondary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(Icons.qr_code_2, size: 180, color: currentAccount.palette.primary),
            ),
            const SizedBox(height: 16.0),
            BetterText(text: "5RD3-LCTO", size: 20.0, weight: 700, colour: currentAccount.palette.textPrimary),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: BetterText(text: currentAccount.t('close'), colour: currentAccount.palette.primary, weight: 600),
          ),
        ],
      ),
    );
  }

  void _showReviewOpeningPopup(
    BuildContext context,
    Appointment? targetAppt,
    DateTime openingDate, {
    String? openingDocId,
  }) {
    final endOpening = openingDate.add(const Duration(minutes: 60));
    final dateLabel = "${getWeekDay(truncate: true, dateTime: openingDate)}, ${openingDate.day} ${getMonth(truncate: true, dateTime: openingDate)}";
    final timeRange = "${formatDateTimeTime(openingDate)}–${formatDateTimeTime(endOpening)}";

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: currentAccount.t('opening_review'), weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: BetterText(
          text: currentAccount.t('opening_review_body', replacements: [dateLabel, timeRange]),
          size: 14.0,
          colour: currentAccount.palette.textPrimary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: BetterText(text: currentAccount.t('cancel'), colour: currentAccount.palette.primary),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (targetAppt != null) {
                await FirestoreService.updateAppointmentDateTime(targetAppt.id, openingDate);
              } else {
                await FirestoreService.createAppointment(
                  Appointment(
                    id: '',
                    accountId: currentAccount.id,
                    profileId: currentAccount.activeProfile.id,
                    clientName: currentAccount.activeProfile.name,
                    dateTime: openingDate,
                    duration: const Duration(minutes: 30),
                    description: currentAccount.t('follow_up'),
                    status: 'Upcoming',
                  ),
                );
              }
              if (openingDocId != null && openingDocId.isNotEmpty) {
                await FirestoreService.claimOpening(openingDocId);
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(currentAccount.t('opening_claimed'))),
              );
            },
            child: BetterText(text: currentAccount.t('claim_opening'), colour: currentAccount.palette.primary, weight: 600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = currentAccount.palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        centerTitle: true,
        leadingWidth: 56,
        leading: const HelpMenuButton(),
        title: BetterText(text: currentAccount.t('home'), size: 24.0, colour: palette.textPrimary),
        actions: const [Padding(padding: EdgeInsets.only(right: 12.0), child: ProfileIconButton())],
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: FirestoreService.streamAccountAppointments(currentAccount.id),
        builder: (context, snapshot) {
          final appointments = snapshot.data ?? [];
          final upcoming = appointments.where((a) => a.status != 'Done' && a.status != 'Cancelled').toList();
          final nextAppt = upcoming.isNotEmpty ? upcoming.first : null;
          final bool isCheckedIn = nextAppt != null && nextAppt.status == 'Checked in';

          String nextTimeRange = '';
          if (nextAppt != null) {
            nextTimeRange = nextAppt.isDurationUnknown
                ? formatDateTimeTime(nextAppt.dateTime)
                : '${formatDateTimeTime(nextAppt.dateTime)}–${formatDateTimeTime(nextAppt.endDateTime)}';
          }

          return GestureDetector(
            onHorizontalDragEnd: (details) => navigateBySwipe(context, 'home', details),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BetterText(
                          text: "${getWeekDay()}, ${getMonth()} ${getDay()}",
                          size: 22.0,
                          weight: 700,
                          colour: palette.textPrimary,
                        ),
                        BetterText(
                          text: "${upcoming.length} ${currentAccount.t('upcoming_appointments')} • ${currentAccount.t('updated_at', replacements: [getTime()])}",
                          size: 12.0,
                          colour: palette.textSecondary,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BetterText(text: currentAccount.t('virtual_check_in'), weight: 600, colour: palette.textPrimary),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: BetterText(
                                text: isCheckedIn ? currentAccount.t('checked_in') : currentAccount.t('available_now'),
                                colour: palette.primary,
                                weight: 600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BetterText(
                                  text: nextAppt?.clientName ?? currentAccount.activeProfile.name,
                                  weight: 600,
                                  colour: palette.textPrimary,
                                ),
                                BetterText(
                                  text: nextAppt != null
                                      ? "${currentAccount.translateAppointmentType(nextAppt.description)} • $nextTimeRange"
                                      : currentAccount.t('no_upcoming_booking'),
                                  colour: palette.textSecondary,
                                ),
                              ],
                            ),
                            isCheckedIn
                                ? OutlinedButton(
                                    onPressed: () => _showCodePopup(context),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: palette.primary, width: 1.5),
                                    ),
                                    child: BetterText(
                                      text: currentAccount.t('show_code'),
                                      colour: palette.primary,
                                      weight: 600,
                                    ),
                                  )
                                : FilledButton(
                                    onPressed: nextAppt == null
                                        ? null
                                        : () async {
                                            await FirestoreService.updateAppointmentStatus(nextAppt.id, 'Checked in');
                                          },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: palette.primary,
                                    ),
                                    child: BetterText(
                                      text: currentAccount.t('check_in'),
                                      colour: Colors.white,
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: StreamBuilder<List<Announcement>>(
                      stream: FirestoreService.streamNotifications(currentAccount.id),
                      builder: (context, notifSnapshot) {
                        final notifications = notifSnapshot.data ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BetterText(text: currentAccount.t('announcements'), size: 22.0, weight: 600, colour: palette.textPrimary),
                            if (notifications.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: BetterText(
                                  text: currentAccount.t('no_announcements'),
                                  size: 13.0,
                                  colour: palette.textSecondary,
                                ),
                              )
                            else
                              for (int i = 0; i < notifications.length; i++)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.fromLTRB(24.0, 12.0, 40.0, 12.0),
                                        decoration: ShapeDecoration(
                                          color: palette.announcementColors[i % palette.announcementColors.length].withAlpha(25),
                                          shape: BoxBorder.fromLTRB(
                                            left: BorderSide(
                                              color: palette.announcementColors[i % palette.announcementColors.length],
                                              width: 4.0,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            BetterText(text: notifications[i].title, weight: 600, colour: palette.textPrimary),
                                            BetterText(text: notifications[i].description, colour: palette.textPrimary),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: IconButton(
                                          icon: Icon(Icons.close, size: 18, color: palette.textSecondary),
                                          onPressed: () {
                                            FirestoreService.dismissNotification(currentAccount.id, notifications[i].id);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BetterText(text: currentAccount.t('upcoming'), size: 22.0, weight: 600, colour: palette.textPrimary),
                        if (snapshot.connectionState == ConnectionState.waiting && appointments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (upcoming.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: BetterText(
                              text: currentAccount.t('no_upcoming_booking'),
                              colour: palette.textSecondary,
                            ),
                          )
                        else
                          for (final appt in upcoming)
                            UpcomingAppointment(appointment: appt),
                      ],
                    ),
                  ),
                  StreamBuilder<List<ClinicOpening>>(
                    stream: FirestoreService.streamOpenings(),
                    builder: (context, openingsSnap) {
                      return StreamBuilder<List<BookedSlot>>(
                        stream: FirestoreService.streamBookedSlots(),
                        builder: (context, slotsSnap) {
                          return StreamBuilder<List<WaitlistEntry>>(
                            stream: FirestoreService.streamWaitlistForAccount(currentAccount.id),
                            builder: (context, waitlistSnap) {
                              final openings = openingsSnap.data ?? [];
                              final bookedSlots = slotsSnap.data ?? [];
                              final waitlistEntries = waitlistSnap.data ?? [];
                              final nextOpening = _computeNextAvailableOpening(openings, bookedSlots);
                              final openingDocId = openings.isNotEmpty ? openings.first.id : null;
                              final nextOpeningEnd = nextOpening.add(const Duration(minutes: 60));
                              final activeWaitlist = waitlistEntries.isNotEmpty ? waitlistEntries.first : null;

                              return Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: palette.smoke, width: 1.5),
                                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                                  color: palette.secondary,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    BetterText(text: currentAccount.t('available_opening'), weight: 600, colour: palette.textPrimary),
                                    BetterText(
                                      text: "${getWeekDay(truncate: true, dateTime: nextOpening)}, ${nextOpening.day} ${getMonth(truncate: true, dateTime: nextOpening)} • ${formatDateTimeTime(nextOpening)}–${formatDateTimeTime(nextOpeningEnd)}",
                                      weight: 600,
                                      size: 18.0,
                                      colour: palette.textPrimary,
                                    ),
                                    BetterText(
                                      text: currentAccount.t(
                                        "bring_appointment_forward",
                                        replacements: [
                                          "${(upcoming.isNotEmpty ? upcoming.last.dateTime : nextOpening).day}",
                                          getMonth(truncate: true, dateTime: upcoming.isNotEmpty ? upcoming.last.dateTime : nextOpening),
                                          currentAccount.translateAppointmentType(
                                            upcoming.isNotEmpty ? upcoming.last.description : currentAccount.t('follow_up'),
                                          ).toLowerCase(),
                                        ],
                                      ),
                                      colour: palette.textSecondary,
                                    ),
                                    const SizedBox(height: 8.0),
                                    TextButton(
                                      onPressed: () => _showReviewOpeningPopup(
                                        context,
                                        upcoming.isNotEmpty ? upcoming.last : null,
                                        nextOpening,
                                        openingDocId: openingDocId,
                                      ),
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(color: palette.smoke, width: 1.5),
                                          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                                        ),
                                        backgroundColor: palette.background,
                                      ),
                                      child: BetterText(text: currentAccount.t('review_opening'), weight: 600, colour: palette.textPrimary),
                                    ),
                                    const SizedBox(height: 6.0),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        if (activeWaitlist != null) {
                                          await FirestoreService.leaveWaitlist(activeWaitlist.id);
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(currentAccount.t('waitlist_left'))),
                                          );
                                        } else {
                                          await FirestoreService.joinWaitlist(
                                            WaitlistEntry(
                                              id: '',
                                              accountId: currentAccount.id,
                                              profileId: currentAccount.activeProfile.id,
                                              clientName: currentAccount.activeProfile.name,
                                              preferredDateTime: nextOpening,
                                              appointmentType: upcoming.isNotEmpty
                                                  ? upcoming.last.description
                                                  : currentAccount.t('follow_up'),
                                            ),
                                          );
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(currentAccount.t('waitlist_joined'))),
                                          );
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: activeWaitlist != null ? Colors.red : palette.primary,
                                          width: 1.5,
                                        ),
                                        backgroundColor: palette.background,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                                        ),
                                      ),
                                      icon: Icon(
                                        activeWaitlist != null ? Icons.notifications_off_outlined : Icons.hourglass_top,
                                        size: 18,
                                        color: activeWaitlist != null ? Colors.red : palette.primary,
                                      ),
                                      label: BetterText(
                                        text: activeWaitlist != null
                                            ? currentAccount.t('on_waitlist')
                                            : currentAccount.t('join_waitlist'),
                                        weight: 600,
                                        colour: activeWaitlist != null ? Colors.red : palette.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddClinicPage()),
                      ).then((_) {
                        if (mounted) setState(() {});
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: palette.primary, width: 1.5),
                      backgroundColor: palette.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    icon: Icon(Icons.add_location_alt_outlined, color: palette.primary),
                    label: BetterText(
                      text:
                          'Find & add a clinic (${currentAccount.activeProfile.clinicIds.length} on ${currentAccount.activeProfile.name})',
                      colour: palette.textPrimary,
                      weight: 600,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const NavigationFooter(currentPage: 'home'),
    );
  }
}