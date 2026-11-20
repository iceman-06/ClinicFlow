import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/pages/components.dart';
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
                      Text(
                        getTime(
                          timeOfDay: TimeOfDay(
                            hour: date.hour,
                            minute: date.minute,
                          ),
                        ),
                      ),
                      BetterText(
                        text: getTime(
                          timeOfDay: TimeOfDay(
                            hour: date.add(duration).hour,
                            minute: date.add(duration).minute,
                          ),
                        ),
                        size: 11.0,
                        colour: const Color.fromARGB(255, 40, 40, 40),
                      ),
                    ],
                  ),
                  const VerticalDivider(
                    thickness: 1.5,
                    width: 30.0,
                    color: Colours.eggWhite,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(name),
                      BetterText(
                        text:
                            "${getWeekDay(truncate: true, dateTime: date)}, ${getDay(dateTime: date)} ${getMonth(truncate: true, dateTime: date)} • $description • ${duration.inMinutes} min",
                        size: 11.0,
                        colour: const Color.fromARGB(255, 40, 40, 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: BetterText(text: status, size: 12.0),
                  ),
                  const Icon(Icons.keyboard_arrow_right),
                ],
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
          BetterText(text: title, weight: 600),
          Text(description),
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
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BetterText(text: 'Home', size: 30.0),
            CircleAvatar(
              backgroundColor: Colours.eggWhite,
              child: Text(currentAccount.initials),
            ),
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
                  ),
                  BetterText(
                    text: "0 upcoming appointments • Updated ${getTime()}",
                    size: 12.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BetterText(text: "Virtual check-in", weight: 600),
                      TextButton(
                        onPressed: () {},
                        child: const BetterText(
                          text: "Available now",
                          colour: Colours.green,
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
                          const BetterText(text: "Jamie Chen", weight: 600),
                          const Text("Follow-up appointment • 14:30-15:00"),
                        ],
                      ),
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: Colours.green,
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
                  const BetterText(text: "Announcements", size: 22.0, weight: 600),
                  const Announcement(
                    title: "Appointment in 20 minutes",
                    description: "Jamie Chen • Today, 14:30-15:00",
                    colour: Colours.green,
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
                  const BetterText(text: "Upcoming", size: 22.0, weight: 600),
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
                border: Border.all(color: Colours.lightSmoke, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                color: Colours.thinGreen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BetterText(text: "Available opening", weight: 600),
                  const BetterText(
                    text: "Tue, 10 Nov • 09:00-09:30",
                    weight: 600,
                    size: 18.0,
                  ),
                  const BetterText(
                    text: "Bring your 12 Feb specialist appointment forward.",
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colours.lightSmoke, width: 1.5),
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const BetterText(text: "Review opening", weight: 600),
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