import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/pages/components.dart';
import 'package:clinicflow/main.dart';

// Probably should turn this into stateless
class UpcomingAppointment extends StatefulWidget {
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
  State<StatefulWidget> createState() => _UpcomingAppointmentState();
}

class _UpcomingAppointmentState extends State<UpcomingAppointment> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.0),
      // IntrinsicHeight is used to allows VerticalDivider to work & to fix alignment
      child: IntrinsicHeight(
        // Stack & Align are used to allow overlapping
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // Shrinks Row to fit its content
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        getTime(
                          timeOfDay: TimeOfDay(
                            hour: widget.date.hour,
                            minute: widget.date.minute,
                          ),
                        ),
                      ),
                      BetterText(
                        text: getTime(
                          timeOfDay: TimeOfDay(
                            hour: widget.date.add(widget.duration).hour,
                            minute: widget.date.add(widget.duration).minute,
                          ),
                        ),
                        size: 11.0,
                        colour: Color.fromARGB(255, 40, 40, 40),
                      ),
                    ],
                  ),
                  VerticalDivider(
                    thickness: 1.5,
                    width: 30.0,
                    color: Colours.eggWhite,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.name),
                      BetterText(
                        text:
                            "${getWeekDay(truncate: true, dateTime: widget.date)}, ${getDay(dateTime: widget.date)} ${getMonth(truncate: true, dateTime: widget.date)} • ${widget.description} • ${widget.duration.inMinutes} min",
                        size: 11.0,
                        colour: Color.fromARGB(255, 40, 40, 40),
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
                  Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    child: BetterText(text: widget.status, size: 12.0),
                  ),
                  Icon(Icons.keyboard_arrow_right),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Probably should turn this into stateless
class Announcement extends StatefulWidget {
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
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      decoration: ShapeDecoration(
        color: widget.colour.withAlpha(
          (widget.colour.a * 25).toInt(),
        ), // Colours work very weirdly
        shape: BoxBorder.fromLTRB(
          left: BorderSide(color: widget.colour, width: 4.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BetterText(text: widget.title, weight: 600),
          Text(widget.description),
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
            BetterText(text: 'Home', size: 30.0),
            CircleAvatar(backgroundColor: Colours.eggWhite, child: Text("JD")),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 6.0),
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
                      BetterText(text: "Virtual check-in", weight: 600),
                      TextButton(
                        onPressed: () {},
                        child: BetterText(
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
                          BetterText(text: "Jamie Chen", weight: 600),
                          Text("Follow-up appointment • 14:30-15:00"),
                        ],
                      ),
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: Colours.green,
                        ),
                        child: BetterText(
                          text: "Check in",
                          colour: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BetterText(text: "Announcements", size: 22.0, weight: 600),
                  Announcement(
                    title: "Appointment in 20 minutes",
                    description: "Jamie Chen • Today, 14:30-15:00",
                    colour: Colours.green,
                  ),
                  Announcement(
                    title: "Medication reminder",
                    description: "Remember to follow your prescribed schedule",
                    colour: Color.fromARGB(255, 160, 78, 57),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BetterText(text: "Upcoming", size: 22.0, weight: 600),
                  UpcomingAppointment(
                    name: "Jamie Chen",
                    date: DateTime(2026, 11, 9, 14, 30),
                    duration: Duration(minutes: 30),
                    description: "Follow-up",
                    status: "Upcoming",
                  ),
                  UpcomingAppointment(
                    name: "Daniel Chen",
                    date: DateTime(2026, 11, 10, 10, 0),
                    duration: Duration(minutes: 45),
                    description: "Initial consultation",
                    status: "Upcoming",
                  ),
                  UpcomingAppointment(
                    name: "Jamie Chen",
                    date: DateTime(2027, 2, 12, 11, 0),
                    duration: Duration(minutes: 30),
                    description: "Specialist consultation",
                    status: "Confirmed",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationFooter(),
    );
  }
}
