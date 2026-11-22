import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';

class StaffBookingCard extends StatefulWidget {
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
  State<StaffBookingCard> createState() => _StaffBookingCardState();
}

class _StaffBookingCardState extends State<StaffBookingCard> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.status;
  }

  void _showStaffAppointmentPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: currentAccount.palette.background,
          title: BetterText(text: "Appointment Details", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BetterText(text: "Client: ${widget.name}", weight: 600, size: 15.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 8.0),
              BetterText(text: "Time: ${widget.startTime} - ${widget.endTime.isEmpty ? 'Ongoing' : widget.endTime}", size: 14.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 6.0),
              BetterText(text: "Details: ${widget.description}", size: 14.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 12.0),
              BetterText(text: "Change Status:", weight: 600, size: 13.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 6.0),
              DropdownButton<String>(
                value: currentStatus,
                dropdownColor: currentAccount.palette.background,
                items: ["Checked in", "Expected", "In progress", "No-show", "Done"]
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: BetterText(text: status, colour: currentAccount.palette.textPrimary),
                        ))
                    .toList(),
                onChanged: (newVal) {
                  if (newVal != null) {
                    setDialogState(() {
                      currentStatus = newVal;
                    });
                    setState(() {});
                  }
                },
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Appointment cancelled")),
                );
              },
              child: const BetterText(text: "Cancel Appointment", colour: Colors.red, weight: 600),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: BetterText(text: "Done", colour: currentAccount.palette.primary, weight: 600),
            ),
          ],
        ),
      ),
    );
  }

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
                BetterText(text: widget.startTime, weight: 600, size: 14.0, colour: currentAccount.palette.textPrimary),
                BetterText(
                  text: widget.endTime,
                  size: 14.0,
                  colour: currentAccount.palette.textSecondary,
                ),
              ],
            ),
            VerticalDivider(
              thickness: 1.5,
              width: 30.0,
              color: currentAccount.palette.eggWhite,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BetterText(text: widget.name, weight: 600, size: 15.0, colour: currentAccount.palette.textPrimary),
                  const SizedBox(height: 2.0),
                  BetterText(
                    text: widget.description,
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
                    text: currentStatus,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BetterText(
                  text: "${getWeekDay(dateTime: DateTime(2026, 11, 9))}, ${getMonth(dateTime: DateTime(2026, 11, 9))} ${getDay(dateTime: DateTime(2026, 11, 9))}",
                  size: 22.0,
                  weight: 700,
                  colour: currentAccount.palette.textPrimary,
                ),
                const SizedBox(height: 2.0),
                BetterText(
                  text: "8 bookings today · Updated 14:10",
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
                        text: "Schedule status",
                        weight: 600,
                        size: 16.0,
                        colour: currentAccount.palette.textPrimary,
                      ),
                      BetterText(
                        text: "2 yet to arrive",
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
                            text: "3",
                            size: 22.0,
                            weight: 700,
                            colour: currentAccount.palette.primary,
                          ),
                          const SizedBox(height: 2.0),
                          Row(
                            children: [
                              BetterText(text: "● ", colour: currentAccount.palette.primary, size: 10.0),
                              const BetterText(text: "Done", size: 12.0, colour: Color.fromARGB(255, 100, 100, 100)),
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
                BetterText(
                  text: "Up next",
                  size: 18.0,
                  weight: 600,
                  colour: currentAccount.palette.textPrimary,
                ),
                BetterText(
                  text: "3 bookings",
                  size: 12.0,
                  colour: currentAccount.palette.textSecondary,
                ),
              ],
            ),
            Divider(thickness: 1.0, color: currentAccount.palette.smoke, height: 16.0),
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
            BetterText(
              text: "On the schedule",
              size: 18.0,
              weight: 600,
              colour: currentAccount.palette.textPrimary,
            ),
            Divider(thickness: 1.0, color: currentAccount.palette.smoke, height: 16.0),
            StaffBookingCard(
              startTime: "14:00",
              endTime: "",
              name: "Mia Patel",
              description: "Follow-up · Room 2",
              status: "In progress",
              statusColor: currentAccount.palette.primary,
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