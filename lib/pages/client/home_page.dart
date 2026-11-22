import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';

class UpcomingAppointment extends StatelessWidget {
  final String name;
  final DateTime date;
  final Duration duration;
  final String description;
  final String status;

  const UpcomingAppointment({
    super.key,
    required this.name,
    required this.duration,
    required this.date,
    required this.description,
    required this.status,
  });

  void _showAppointmentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: "Appointment Details", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BetterText(text: "Patient: $name", weight: 600, size: 15.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 8.0),
            BetterText(text: "Date: ${getWeekDay(dateTime: date)}, ${getMonth(dateTime: date)} ${getDay(dateTime: date)} ${date.year}", size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: "Time: ${getTime(timeOfDay: TimeOfDay(hour: date.hour, minute: date.minute))} (${duration.inMinutes} min)", size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: "Description: $description", size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: "Status: $status", size: 14.0, colour: currentAccount.palette.primary),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Appointment cancelled successfully")),
              );
            },
            child: const BetterText(text: "Cancel Appointment", colour: Colors.red, weight: 600),
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
                      BetterText(text: name, colour: currentAccount.palette.textPrimary),
                      BetterText(
                        text:
                            "${getWeekDay(truncate: true, dateTime: date)}, ${getDay(dateTime: date)} ${getMonth(truncate: true, dateTime: date)} • $description • ${duration.inMinutes} min",
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
                      child: BetterText(text: status, size: 12.0, colour: currentAccount.palette.textPrimary),
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
  bool _checkedIn = false;
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
        title: BetterText(text: "Check-in Pass", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
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

  void _showReviewOpeningPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: "Opening Review", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: BetterText(
          text: "Available opening on Tue, 10 Nov • 09:00-09:30. Would you like to bring your appointment forward?",
          size: 14.0,
          colour: currentAccount.palette.textPrimary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: BetterText(text: currentAccount.t('cancel'), colour: currentAccount.palette.primary),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Opening claimed successfully!")),
              );
            },
            child: BetterText(text: "Claim Opening", colour: currentAccount.palette.primary, weight: 600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {}); // Ensure real-time language & palette reactivity
    final palette = currentAccount.palette;

    for (int i = 0; i < _announcements.length; i++) {
      // Refresh announcement colors mapping dynamically
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BetterText(text: currentAccount.t('home'), size: 30.0, colour: palette.textPrimary),
            const ProfileIconButton(),
          ],
        ),
      ),
      body: SingleChildScrollView(
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
                    text: "0 upcoming appointments • Updated ${getTime()}",
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
                          text: _checkedIn ? currentAccount.t('checked_in') : currentAccount.t('available_now'),
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
                          BetterText(text: "Jamie Chen", weight: 600, colour: palette.textPrimary),
                          BetterText(text: "Follow-up appointment • 14:30-15:00", colour: palette.textSecondary),
                        ],
                      ),
                      _checkedIn
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
                              onPressed: () {
                                setState(() {
                                  _checkedIn = true;
                                });
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
                  UpcomingAppointment(
                    name: "Jamie Chen",
                    date: DateTime(2026, 11, 9, 14, 30),
                    duration: const Duration(minutes: 30),
                    description: "Follow-up",
                    status: "Upcoming",
                  ),
                  UpcomingAppointment(
                    name: "Daniel Chen",
                    date: DateTime(2026, 11, 10, 10, 0),
                    duration: const Duration(minutes: 45),
                    description: "Initial consultation",
                    status: "Upcoming",
                  ),
                  UpcomingAppointment(
                    name: "Jamie Chen",
                    date: DateTime(2027, 2, 12, 11, 0),
                    duration: const Duration(minutes: 30),
                    description: "Specialist consultation",
                    status: "Confirmed",
                  ),
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
                    text: "Tue, 10 Nov • 09:00-09:30",
                    weight: 600,
                    size: 18.0,
                    colour: palette.textPrimary,
                  ),
                  BetterText(
                    text: "Bring your 12 Feb specialist appointment forward.",
                    colour: palette.textSecondary,
                  ),
                  TextButton(
                    onPressed: () => _showReviewOpeningPopup(context),
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
      bottomNavigationBar: const NavigationFooter(currentPage: 'home'),
    );
  }
}