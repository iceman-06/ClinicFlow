import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/services/firestore_service.dart';

class UpcomingAppointment extends StatelessWidget {
  final Appointment appointment;

  const UpcomingAppointment({
    super.key,
    required this.appointment,
  });

  void _showAppointmentPopup(BuildContext context) {
    final date = appointment.dateTime;
    final duration = appointment.duration;

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
            BetterText(text: currentAccount.t('time_label', replacements: ["${getTime(timeOfDay: TimeOfDay(hour: date.hour, minute: date.minute))} (${duration.inMinutes} min)"]), size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: currentAccount.t('description_label', replacements: [appointment.description]), size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: currentAccount.t('status_label', replacements: [appointment.status]), size: 14.0, colour: currentAccount.palette.primary),
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
    final duration = appointment.duration;

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
                        text: getTime(
                          timeOfDay: TimeOfDay(
                            hour: date.hour,
                            minute: date.minute,
                          ),
                        ),
                        colour: currentAccount.palette.textPrimary,
                      ),
                      BetterText(
                        text: getTime(
                          timeOfDay: TimeOfDay(
                            hour: date.add(duration).hour,
                            minute: date.add(duration).minute,
                          ),
                        ),
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
                            "${getWeekDay(truncate: true, dateTime: date)}, ${getDay(dateTime: date)} ${getMonth(truncate: true, dateTime: date)} • ${appointment.description} • ${duration.inMinutes} min",
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
                      child: BetterText(text: appointment.status, size: 12.0, colour: currentAccount.palette.textPrimary),
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
  late List<Announcement> _announcements;

  @override
  void initState() {
    super.initState();
    _announcements = Announcement.retrieveAnnouncements();
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

  void _showReviewOpeningPopup(BuildContext context, Appointment? targetAppt, DateTime openingDate) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: currentAccount.t('opening_review'), weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: BetterText(
          text: "Available opening on ${getWeekDay(truncate: true, dateTime: openingDate)}, ${openingDate.day} ${getMonth(truncate: true, dateTime: openingDate)} • 09:00-09:30. Would you like to bring your appointment forward?",
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
    final now = DateTime.now();
    final tomorrowOpening = DateTime(now.year, now.month, now.day + 1, 9, 0);

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

          String nextTimeRange = '14:30–15:00';
          if (nextAppt != null) {
            final start = TimeOfDay(hour: nextAppt.dateTime.hour, minute: nextAppt.dateTime.minute);
            final endDt = nextAppt.dateTime.add(nextAppt.duration);
            final end = TimeOfDay(hour: endDt.hour, minute: endDt.minute);
            nextTimeRange = '${getTime(timeOfDay: start)}–${getTime(timeOfDay: end)}';
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
                          text: "${upcoming.length} ${currentAccount.t('upcoming_appointments')} • Updated ${getTime()}",
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
                                      ? "${nextAppt.description} • $nextTimeRange"
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        BetterText(text: currentAccount.t('announcements'), size: 22.0, weight: 600, colour: palette.textPrimary),
                        for (int i = 0; i < _announcements.length; i++)
                          if (_announcements[i].isVisible)
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
                                      shape: BoxBorder.fromLTRB(left: BorderSide(color: palette.announcementColors[i % palette.announcementColors.length], width: 4.0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        BetterText(text: _announcements[i].title, weight: 600, colour: palette.textPrimary),
                                        BetterText(text: _announcements[i].description, colour: palette.textPrimary),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: IconButton(
                                      icon: Icon(Icons.close, size: 18, color: palette.textSecondary),
                                      onPressed: () {
                                        setState(() {
                                          _announcements[i].isVisible = false;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
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
                  Container(
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
                          text: "${getWeekDay(truncate: true, dateTime: tomorrowOpening)}, ${tomorrowOpening.day} ${getMonth(truncate: true, dateTime: tomorrowOpening)} • 09:00-09:30",
                          weight: 600,
                          size: 18.0,
                          colour: palette.textPrimary,
                        ),
                        BetterText(
                          text: currentAccount.t(
                            "bring_appointment_forward",
                            replacements: [
                              "${(upcoming.isNotEmpty ? upcoming.last.dateTime : tomorrowOpening).day}",
                              getMonth(truncate: true, dateTime: upcoming.isNotEmpty ? upcoming.last.dateTime : tomorrowOpening),
                              (upcoming.isNotEmpty ? upcoming.last.description : "follow-up").toLowerCase(),
                            ],
                          ),
                          colour: palette.textSecondary,
                        ),
                        TextButton(
                          onPressed: () => _showReviewOpeningPopup(
                            context,
                            upcoming.isNotEmpty ? upcoming.last : null,
                            tomorrowOpening,
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
                      ],
                    ),
                  ),
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