import 'package:clinicflow/main.dart';
import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/pages/components.dart';

class CalendarCell extends StatelessWidget {
  final int? dayNumber;
  final bool isSelected;
  final bool canSelect;
  final VoidCallback? onTap;
  final bool hasDot;

  const CalendarCell({
    super.key,
    required this.dayNumber,
    required this.isSelected,
    required this.canSelect,
    required this.onTap,
    this.hasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    if (dayNumber == null) {
      return Container();
    }

    return TextButton(
      onPressed: canSelect ? onTap : null,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
      ),
      child: Container(
        alignment: Alignment.center,
        color: isSelected ? Colours.green : Colors.white,
        child: BetterText(
          text: "$dayNumber${hasDot ? "\n●" : "\n○"}",
          colour: canSelect
              ? (isSelected ? Colors.white : Colors.black)
              : Colors.grey,
          align: TextAlign.center,
        ),
      ),
    );
  }
}

class Calendar extends StatelessWidget {
  final int offset;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  const Calendar({
    super.key,
    required this.offset,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final targetDate = DateTime(now.year, now.month + offset, 1);
    final year = targetDate.year;
    final month = targetDate.month;

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayWeekday = targetDate.weekday; // 1 = Mon, 7 = Sun
    final leadingSpaces = firstDayWeekday - 1;

    return GridView.count(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      primary: false,
      crossAxisCount: 7,
      mainAxisExtent: 40.0,
      shrinkWrap: true,
      children: <Widget>[
        for (String dayLabel in ["M", "T", "W", "T", "F", "S", "S"])
          Container(
            alignment: Alignment.center,
            child: BetterText(text: dayLabel),
          ),
        for (int n = 0; n < 42; n++) ...[
          if (n < leadingSpaces || n >= leadingSpaces + daysInMonth)
            const CalendarCell(
              dayNumber: null,
              isSelected: false,
              canSelect: false,
              onTap: null,
            )
          else ...[
            () {
              final dayNum = n - leadingSpaces + 1;
              return CalendarCell(
                dayNumber: dayNum,
                isSelected: selectedDay == dayNum,
                canSelect: true,
                onTap: () => onDaySelected(dayNum),
                hasDot: false, // Wire up your appointment check here if needed
              );
            }(),
          ],
        ],
      ],
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _offset = 0;
  int _selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    final targetDate = DateTime(
      DateTime.now().year,
      DateTime.now().month + _offset,
      1,
    );

    // Ensure selectedDay doesn't exceed the days in the newly selected month
    final daysInCurrentMonth = DateTime(
      targetDate.year,
      targetDate.month + 1,
      0,
    ).day;
    if (_selectedDay > daysInCurrentMonth) {
      _selectedDay = daysInCurrentMonth;
    }

    final selectedDateTime = DateTime(
      targetDate.year,
      targetDate.month,
      _selectedDay,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BetterText(text: 'Calendar', size: 30.0),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BetterText(
                        text:
                            "${getMonth(dateTime: targetDate)} ${targetDate.year}",
                        size: 18.0,
                        weight: 600,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          BetterText(text: "Week"),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _offset -= 1;
                                _selectedDay =
                                    1; // Reset to 1st on month change
                              });
                            },
                            icon: const Icon(Icons.keyboard_arrow_left),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _offset += 1;
                                _selectedDay =
                                    1; // Reset to 1st on month change
                              });
                            },
                            icon: const Icon(Icons.keyboard_arrow_right),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Calendar(
                    offset: _offset,
                    selectedDay: _selectedDay,
                    onDaySelected: (day) {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            BetterText(
              text: "● Booked appointment ○ Open booking times",
              weight: 500,
            ),
            const SizedBox(height: 12.0),
            BetterText(
              text:
                  "${getWeekDay(dateTime: selectedDateTime)}, ${getMonth(dateTime: targetDate)}, $_selectedDay",
              size: 22.0,
              weight: 600,
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationFooter(),
    );
  }
}
