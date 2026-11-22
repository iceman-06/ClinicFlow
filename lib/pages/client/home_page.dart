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
            child: BetterText(text: "Close", colour: currentAccount.palette.primary, weight: 600),
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
                  VerticalDivider(
                    thickness: 1.5,
                    width: 30.0,
                    color: currentAccount.palette.eggWhite,
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

class Announcement extends StatelessWidget {
  final String title;
  final String description;
  final Color colour;

  const Announcement({
    super.key,
    required this.title,
    required this.description,
    required this.colour,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: ShapeDecoration(
        color: colour.withAlpha((colour.a * 25).toInt()),
        shape: BoxBorder.fromLTRB(left: BorderSide(color: colour, width: 4.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BetterText(text: title, weight: 600, colour: currentAccount.palette.textPrimary),
          BetterText(text: description, colour: currentAccount.palette.textPrimary),
        ],
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentAccount.palette.background,
      appBar: AppBar(
        backgroundColor: currentAccount.palette.background,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BetterText(text: 'Home', size: 30.0, colour: currentAccount.palette.textPrimary),
            const ProfileIconButton(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    colour: currentAccount.palette.textPrimary,
                  ),
                  BetterText(
                    text: "0 upcoming appointments • Updated ${getTime()}",
                    size: 12.0,
                    colour: currentAccount.palette.textSecondary,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BetterText(text: "Virtual check-in", weight: 600, colour: currentAccount.palette.textPrimary),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: BetterText(
                          text: "Available now",
                          colour: currentAccount.palette.primary,
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
                          BetterText(text: "Jamie Chen", weight: 600, colour: currentAccount.palette.textPrimary),
                          BetterText(text: "Follow-up appointment • 14:30-15:00", colour: currentAccount.palette.textSecondary),
                        ],
                      ),
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: currentAccount.palette.primary,
                        ),
                        child: const BetterText(
                          text: "Check in",
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BetterText(text: "Announcements", size: 22.0, weight: 600, colour: currentAccount.palette.textPrimary),
                  Announcement(
                    title: "Appointment in 20 minutes",
                    description: "Jamie Chen • Today, 14:30-15:00",
                    colour: currentAccount.palette.primary,
                  ),
                  Announcement(
                    title: "Medication reminder",
                    description: "Remember to follow your prescribed schedule",
                    colour: const Color.fromARGB(255, 160, 78, 57),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BetterText(text: "Upcoming", size: 22.0, weight: 600, colour: currentAccount.palette.textPrimary),
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
                border: Border.all(color: currentAccount.palette.smoke, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                color: currentAccount.palette.secondary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BetterText(text: "Available opening", weight: 600, colour: currentAccount.palette.textPrimary),
                  BetterText(
                    text: "Tue, 10 Nov • 09:00-09:30",
                    weight: 600,
                    size: 18.0,
                    colour: currentAccount.palette.textPrimary,
                  ),
                  BetterText(
                    text: "Bring your 12 Feb specialist appointment forward.",
                    colour: currentAccount.palette.textSecondary,
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: currentAccount.palette.smoke, width: 1.5),
                        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                      ),
                      backgroundColor: currentAccount.palette.background,
                    ),
                    child: BetterText(text: "Review opening", weight: 600, colour: currentAccount.palette.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavigationFooter(),
    );
  }
}