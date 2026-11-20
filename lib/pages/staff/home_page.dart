import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/pages/components.dart';
import 'package:clinicflow/models/account.dart';

class StaffBookingCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final String name;
  final String description;
  final String status;
  final Color? statusColor;

  const StaffBookingCard({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.name,
    required this.description,
    required this.status,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BetterText(text: startTime, weight: 600, size: 14.0),
                BetterText(
                  text: endTime,
                  size: 14.0,
                  colour: const Color.fromARGB(255, 120, 120, 120),
                ),
              ],
            ),
            const VerticalDivider(
              thickness: 1.5,
              width: 30.0,
              color: Colours.eggWhite,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BetterText(text: name, weight: 600, size: 15.0),
                  const SizedBox(height: 2.0),
                  BetterText(
                    text: description,
                    size: 12.0,
                    colour: const Color.fromARGB(255, 120, 120, 120),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BetterText(
                  text: status,
                  size: 13.0,
                  weight: 600,
                  colour: statusColor ?? Colors.black,
                ),
                const SizedBox(width: 4.0),
                const Icon(Icons.keyboard_arrow_right, size: 20),
              ],
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BetterText(
                  text: "${getWeekDay(dateTime: DateTime(2026, 11, 9))}, ${getMonth(dateTime: DateTime(2026, 11, 9))} ${getDay(dateTime: DateTime(2026, 11, 9))}",
                  size: 22.0,
                  weight: 700,
                ),
                const SizedBox(height: 2.0),
                const BetterText(
                  text: "8 bookings today · Updated 14:10",
                  size: 12.0,
                  colour: Color.fromARGB(255, 120, 120, 120),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colours.lightSmoke, width: 1.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BetterText(
                        text: "Schedule status",
                        weight: 600,
                        size: 16.0,
                      ),
                      const BetterText(
                        text: "2 yet to arrive",
                        size: 12.0,
                        colour: Color.fromARGB(255, 120, 120, 120),
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
                          const BetterText(
                            text: "3",
                            size: 22.0,
                            weight: 700,
                            colour: Colours.green,
                          ),
                          const SizedBox(height: 2.0),
                          Row(
                            children: const [
                              BetterText(text: "● ", colour: Colours.green, size: 10.0),
                              BetterText(text: "Done", size: 12.0, colour: Color.fromARGB(255, 100, 100, 100)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BetterText(
                            text: "1",
                            size: 22.0,
                            weight: 700,
                            colour: Color.fromARGB(255, 41, 128, 185),
                          ),
                          const SizedBox(height: 2.0),
                          Row(
                            children: const [
                              BetterText(text: "● ", colour: Color.fromARGB(255, 41, 128, 185), size: 10.0),
                              BetterText(text: "In progress", size: 12.0, colour: Color.fromARGB(255, 100, 100, 100)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BetterText(
                            text: "1",
                            size: 22.0,
                            weight: 700,
                          ),
                          const SizedBox(height: 2.0),
                          Row(
                            children: const [
                              BetterText(text: "● ", colour: Colors.black, size: 10.0),
                              BetterText(text: "Checked in", size: 12.0, colour: Color.fromARGB(255, 100, 100, 100)),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BetterText(
                            text: "1",
                            size: 22.0,
                            weight: 700,
                            colour: Color.fromARGB(255, 192, 57, 43),
                          ),
                          const SizedBox(height: 2.0),
                          Row(
                            children: const [
                              BetterText(text: "● ", colour: Color.fromARGB(255, 192, 57, 43), size: 10.0),
                              BetterText(text: "No-show", size: 12.0, colour: Color.fromARGB(255, 100, 100, 100)),
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
                const BetterText(
                  text: "Up next",
                  size: 18.0,
                  weight: 600,
                ),
                const BetterText(
                  text: "3 bookings",
                  size: 12.0,
                  colour: Color.fromARGB(255, 120, 120, 120),
                ),
              ],
            ),
            const Divider(thickness: 1.0, color: Colours.eggWhite, height: 16.0),
            const StaffBookingCard(
              startTime: "14:30",
              endTime: "15:00",
              name: "Jamie Chen",
              description: "Follow-up appointment · 30 min",
              status: "Checked in",
            ),
            const StaffBookingCard(
              startTime: "15:15",
              endTime: "16:00",
              name: "Alex Morgan",
              description: "Initial consultation · 45 min",
              status: "Expected",
              statusColor: Color.fromARGB(255, 120, 120, 120),
            ),
            const StaffBookingCard(
              startTime: "16:00",
              endTime: "16:30",
              name: "Priya Shah",
              description: "Follow-up appointment · 30 min",
              status: "Expected",
              statusColor: Color.fromARGB(255, 120, 120, 120),
            ),
            const SizedBox(height: 24.0),
            const BetterText(
              text: "On the schedule",
              size: 18.0,
              weight: 600,
            ),
            const Divider(thickness: 1.0, color: Colours.eggWhite, height: 16.0),
            const StaffBookingCard(
              startTime: "14:00",
              endTime: "",
              name: "Mia Patel",
              description: "Follow-up · Room 2",
              status: "In progress",
              statusColor: Colours.green,
            ),
            const StaffBookingCard(
              startTime: "13:00",
              endTime: "",
              name: "Noah Williams",
              description: "Initial consultation",
              status: "No-show",
              statusColor: Color.fromARGB(255, 192, 57, 43),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
      bottomNavigationBar: const NavigationFooter(),
    );
  }
}