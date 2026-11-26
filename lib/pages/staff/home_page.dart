import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/services/firestore_service.dart';

class StaffBookingCard extends StatefulWidget {
  final Appointment appointment;
  final Color? statusColor;

  const StaffBookingCard({
    super.key,
    required this.appointment,
    this.statusColor,
  });

  @override
  State<StaffBookingCard> createState() => _StaffBookingCardState();
}

class _StaffBookingCardState extends State<StaffBookingCard> {
  static const List<String> _validStatuses = [
    "Upcoming",
    "Confirmed",
    "Checked in",
    "Expected",
    "In progress",
    "No-show",
    "Done",
  ];

  void _showStaffAppointmentPopup(BuildContext context) {
    final dt = widget.appointment.dateTime;
    final endDt = dt.add(widget.appointment.duration);
    final startTime = getTime(timeOfDay: TimeOfDay(hour: dt.hour, minute: dt.minute));
    final endTime = getTime(timeOfDay: TimeOfDay(hour: endDt.hour, minute: endDt.minute));
    String selectedStatus = _validStatuses.contains(widget.appointment.status)
        ? widget.appointment.status
        : "Upcoming";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: currentAccount.palette.background,
          title: BetterText(text: currentAccount.t('appointment_details'), weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BetterText(text: currentAccount.t('client_label', replacements: [widget.appointment.clientName]), weight: 600, size: 15.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 8.0),
              BetterText(text: currentAccount.t('time_label', replacements: ["$startTime – $endTime"]), size: 14.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 6.0),
              BetterText(text: currentAccount.t('description_label', replacements: [widget.appointment.description]), size: 14.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 12.0),
              BetterText(text: currentAccount.t('change_status'), weight: 600, size: 13.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 6.0),
              DropdownButton<String>(
                value: selectedStatus,
                dropdownColor: currentAccount.palette.background,
                items: _validStatuses
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: BetterText(text: status, colour: currentAccount.palette.textPrimary),
                        ))
                    .toList(),
                onChanged: (newVal) async {
                  if (newVal != null) {
                    setDialogState(() {
                      selectedStatus = newVal;
                    });
                    await FirestoreService.updateAppointmentStatus(widget.appointment.id, newVal);
                  }
                },
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await FirestoreService.cancelAppointment(widget.appointment.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(currentAccount.t('appointment_cancelled'))),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dt = widget.appointment.dateTime;
    final endDt = dt.add(widget.appointment.duration);
    final startTime = getTime(timeOfDay: TimeOfDay(hour: dt.hour, minute: dt.minute));
    final endTime = getTime(timeOfDay: TimeOfDay(hour: endDt.hour, minute: endDt.minute));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BetterText(text: startTime, weight: 600, size: 14.0, colour: currentAccount.palette.textPrimary),
                BetterText(
                  text: endTime,
                  size: 14.0,
                  colour: currentAccount.palette.textSecondary,
                ),
              ],
            ),
            const VerticalDivider(
              thickness: 1.5,
              width: 30.0,
              color: Colors.transparent,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BetterText(text: widget.appointment.clientName, weight: 600, size: 15.0, colour: currentAccount.palette.textPrimary),
                  const SizedBox(height: 2.0),
                  BetterText(
                    text: "${getWeekDay(truncate: true, dateTime: dt)}, ${dt.day} ${getMonth(truncate: true, dateTime: dt)} · ${widget.appointment.description} · ${widget.appointment.duration.inMinutes} min",
                    size: 12.0,
                    colour: currentAccount.palette.textSecondary,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => _showStaffAppointmentPopup(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BetterText(
                    text: widget.appointment.status,
                    size: 13.0,
                    weight: 600,
                    colour: widget.statusColor ?? currentAccount.palette.textPrimary,
                  ),
                  const SizedBox(width: 4.0),
                  Icon(Icons.keyboard_arrow_right, size: 20, color: currentAccount.palette.textPrimary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: currentAccount.palette.background,
      appBar: AppBar(
        backgroundColor: currentAccount.palette.background,
        centerTitle: true,
        leadingWidth: 56,
        leading: const HelpMenuButton(),
        title: BetterText(text: currentAccount.t('home'), size: 24.0, colour: currentAccount.palette.textPrimary),
        actions: const [Padding(padding: EdgeInsets.only(right: 12.0), child: ProfileIconButton())],
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: FirestoreService.streamAllAppointments(),
        builder: (context, snapshot) {
          final allAppointments = snapshot.data ?? [];
          final doneCount = allAppointments.where((a) => a.status == 'Done').length;
          final inProgressCount = allAppointments.where((a) => a.status == 'In progress').length;
          final checkedInCount = allAppointments.where((a) => a.status == 'Checked in').length;
          final noShowCount = allAppointments.where((a) => a.status == 'No-show').length;
          final yetToArriveCount = allAppointments
              .where((a) => a.status == 'Upcoming' || a.status == 'Confirmed' || a.status == 'Expected')
              .length;

          final upNext = allAppointments
              .where((a) => a.status == 'Upcoming' || a.status == 'Confirmed' || a.status == 'Expected' || a.status == 'Checked in')
              .toList();
          final onSchedule = allAppointments
              .where((a) => a.status == 'In progress' || a.status == 'No-show' || a.status == 'Done')
              .toList();

          return GestureDetector(
            onHorizontalDragEnd: (details) => navigateBySwipe(context, 'home', details),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BetterText(
                        text: "${getWeekDay(dateTime: now)}, ${getMonth(dateTime: now)} ${getDay(dateTime: now)}",
                        size: 22.0,
                        weight: 700,
                        colour: currentAccount.palette.textPrimary,
                      ),
                      const SizedBox(height: 2.0),
                      BetterText(
                        text: "${allAppointments.length} bookings · Updated ${getTime()}",
                        size: 12.0,
                        colour: currentAccount.palette.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: currentAccount.palette.smoke, width: 1.5),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BetterText(
                              text: currentAccount.t('schedule_status'),
                              weight: 600,
                              size: 16.0,
                              colour: currentAccount.palette.textPrimary,
                            ),
                            BetterText(
                              text: "$yetToArriveCount ${currentAccount.t('yet_to_arrive')}",
                              size: 12.0,
                              colour: currentAccount.palette.textSecondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BetterText(
                                  text: "$doneCount",
                                  size: 22.0,
                                  weight: 700,
                                  colour: currentAccount.palette.primary,
                                ),
                                const SizedBox(height: 2.0),
                                Row(
                                  children: [
                                    BetterText(text: "● ", colour: currentAccount.palette.primary, size: 10.0),
                                    BetterText(text: currentAccount.t('done'), size: 12.0, colour: currentAccount.palette.textSecondary),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BetterText(
                                  text: "$inProgressCount",
                                  size: 22.0,
                                  weight: 700,
                                  colour: const Color.fromARGB(255, 41, 128, 185),
                                ),
                                const SizedBox(height: 2.0),
                                Row(
                                  children: [
                                    const BetterText(text: "● ", colour: Color.fromARGB(255, 41, 128, 185), size: 10.0),
                                    BetterText(text: currentAccount.t('in_progress'), size: 12.0, colour: currentAccount.palette.textSecondary),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BetterText(
                                  text: "$checkedInCount",
                                  size: 22.0,
                                  weight: 700,
                                  colour: currentAccount.palette.textPrimary,
                                ),
                                const SizedBox(height: 2.0),
                                Row(
                                  children: [
                                    BetterText(text: "● ", colour: currentAccount.palette.textPrimary, size: 10.0),
                                    BetterText(text: currentAccount.t('checked_in'), size: 12.0, colour: currentAccount.palette.textSecondary),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BetterText(
                                  text: "$noShowCount",
                                  size: 22.0,
                                  weight: 700,
                                  colour: const Color.fromARGB(255, 192, 57, 43),
                                ),
                                const SizedBox(height: 2.0),
                                Row(
                                  children: [
                                    const BetterText(text: "● ", colour: Color.fromARGB(255, 192, 57, 43), size: 10.0),
                                    BetterText(text: currentAccount.t('no_show'), size: 12.0, colour: currentAccount.palette.textSecondary),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BetterText(
                        text: currentAccount.t('up_next'),
                        size: 18.0,
                        weight: 600,
                        colour: currentAccount.palette.textPrimary,
                      ),
                      BetterText(
                        text: "${upNext.length} bookings",
                        size: 12.0,
                        colour: currentAccount.palette.textSecondary,
                      ),
                    ],
                  ),
                  Divider(thickness: 1.0, color: currentAccount.palette.smoke, height: 16.0),
                  if (snapshot.connectionState == ConnectionState.waiting && allAppointments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (upNext.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: BetterText(
                        text: currentAccount.t('no_upcoming_booking'),
                        colour: currentAccount.palette.textSecondary,
                      ),
                    )
                  else
                    for (final appt in upNext)
                      StaffBookingCard(
                        appointment: appt,
                        statusColor: appt.status == 'Checked in'
                            ? currentAccount.palette.primary
                            : const Color.fromARGB(255, 120, 120, 120),
                      ),
                  const SizedBox(height: 24.0),
                  BetterText(
                    text: currentAccount.t('on_the_schedule'),
                    size: 18.0,
                    weight: 600,
                    colour: currentAccount.palette.textPrimary,
                  ),
                  Divider(thickness: 1.0, color: currentAccount.palette.smoke, height: 16.0),
                  for (final appt in onSchedule)
                    StaffBookingCard(
                      appointment: appt,
                      statusColor: appt.status == 'No-show'
                          ? const Color.fromARGB(255, 192, 57, 43)
                          : currentAccount.palette.primary,
                    ),
                  const SizedBox(height: 24.0),
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