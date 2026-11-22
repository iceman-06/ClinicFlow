import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';

class CalendarCell extends StatefulWidget {
  final int? dayNumber;
  final bool isSelected;
  final bool canSelect;
  final VoidCallback? onTap;
  final bool hasDot;
  final bool hasCircleDot;

  const CalendarCell({
    super.key,
    required this.dayNumber,
    required this.isSelected,
    required this.canSelect,
    required this.onTap,
    this.hasDot = false,
    this.hasCircleDot = false,
  });

  @override
  State<CalendarCell> createState() => _CalendarCellState();
}

class _CalendarCellState extends State<CalendarCell> {
  @override
  Widget build(BuildContext context) {
    if (widget.dayNumber == null) {
      return Container();
    }

    return TextButton(
      onPressed: widget.canSelect ? widget.onTap : null,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
      ),
      child: Container(
        alignment: Alignment.center,
        color: widget.isSelected ? currentAccount.palette.primary : currentAccount.palette.background,
        child: BetterText(
          text: "${widget.dayNumber}${widget.hasDot ? "\n●" : (widget.hasCircleDot ? "\n○" : "")}",
          colour: widget.canSelect
              ? (widget.isSelected ? Colors.white : currentAccount.palette.textPrimary)
              : currentAccount.palette.textSecondary,
          align: TextAlign.center,
        ),
      ),
    );
  }
}

class MonthCalendarView extends StatelessWidget {
  final int offset;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  const MonthCalendarView({
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
    final firstDayWeekday = targetDate.weekday;
    final leadingSpaces = firstDayWeekday - 1;

    return GridView.count(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              bool hasDot = (month == 11 && (dayNum == 9 || dayNum == 10));
              bool hasCircle = !hasDot;

              return CalendarCell(
                key: ValueKey('client_cell_${year}_${month}_$dayNum'),
                dayNumber: dayNum,
                isSelected: selectedDay == dayNum,
                canSelect: true,
                onTap: () => onDaySelected(dayNum),
                hasDot: hasDot,
                hasCircleDot: hasCircle,
              );
            }()
          ]
        ],
      ],
    );
  }
}

class WeekCalendarView extends StatelessWidget {
  final int weekOffset;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  const WeekCalendarView({
    super.key,
    required this.weekOffset,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate start of week (Monday) based on base week Nov 9-15, 2026 + weekOffset * 7 days
    final baseMonday = DateTime(2026, 11, 9);
    final currentMonday = baseMonday.add(Duration(days: weekOffset * 7));

    final weekDays = [];
    for (int i = 0; i < 7; i++) {
      final d = currentMonday.add(Duration(days: i));
      String name = "";
      switch (d.weekday) {
        case 1: name = "Mon"; break;
        case 2: name = "Tue"; break;
        case 3: name = "Wed"; break;
        case 4: name = "Thu"; break;
        case 5: name = "Fri"; break;
        case 6: name = "Sat"; break;
        case 7: name = "Sun"; break;
      }
      weekDays.add({"name": name, "date": d, "day": d.day});
    }

    final hours = [
      "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: currentAccount.palette.smoke, width: 1.0),
              top: BorderSide(color: currentAccount.palette.smoke, width: 1.0),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 50),
              for (var d in weekDays)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onDaySelected(d["day"] as int),
                    child: Column(
                      children: [
                        BetterText(
                          text: d["name"] as String,
                          size: 11.0,
                          colour: currentAccount.palette.textSecondary,
                          align: TextAlign.center,
                        ),
                        const SizedBox(height: 2.0),
                        BetterText(
                          text: "${d["day"]}",
                          size: 13.0,
                          weight: 600,
                          align: TextAlign.center,
                          colour: selectedDay == d["day"] ? currentAccount.palette.primary : currentAccount.palette.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView(
            children: [
              for (String hour in hours)
                SizedBox(
                  height: 35,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 50,
                        child: BetterText(
                          text: hour,
                          size: 11.0,
                          colour: currentAccount.palette.textSecondary,
                        ),
                      ),
                      for (var d in weekDays)
                        Expanded(
                          child: GestureDetector(
                            onTap: () => onDaySelected(d["day"] as int),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: currentAccount.palette.smoke,
                                  width: 0.5,
                                ),
                                color: (d["day"] == 10 && hour == "10:00") ||
                                        (d["day"] == 9 && hour == "14:30")
                                    ? currentAccount.palette.primary
                                    : ((d["day"] == 10 && hour == "11:30") ||
                                            (d["day"] == 11 && hour == "10:00") ||
                                            (d["day"] == 11 && hour == "11:30") ||
                                            (d["day"] == 13 && hour == "10:00") ||
                                            (d["day"] == 12 && hour == "13:00") ||
                                            (d["day"] == 14 && hour == "14:00"))
                                        ? currentAccount.palette.secondary
                                        : Colors.transparent,
                              ),
                              alignment: Alignment.center,
                              child: (d["day"] == 10 && hour == "10:00") ||
                                      (d["day"] == 9 && hour == "14:30") ||
                                      (d["day"] == 10 && hour == "11:30") ||
                                      (d["day"] == 11 && hour == "10:00") ||
                                      (d["day"] == 11 && hour == "11:30") ||
                                      (d["day"] == 13 && hour == "10:00") ||
                                      (d["day"] == 12 && hour == "13:00") ||
                                      (d["day"] == 14 && hour == "14:00")
                                  ? BetterText(
                                      text: hour,
                                      size: 10.0,
                                      colour: (d["day"] == 10 && hour == "10:00") ||
                                              (d["day"] == 9 && hour == "14:30")
                                          ? Colors.white
                                          : currentAccount.palette.textPrimary,
                                      weight: 600,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
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
  int _weekOffset = 0;
  int _selectedDay = 11;
  bool _isWeekView = false;

  @override
  Widget build(BuildContext context) {
    final targetDate = DateTime(
      DateTime.now().year,
      DateTime.now().month + _offset,
      1,
    );

    final baseMonday = DateTime(2026, 11, 9);
    final currentMonday = baseMonday.add(Duration(days: _weekOffset * 7));
    final currentSunday = currentMonday.add(const Duration(days: 6));

    final daysInCurrentMonth = DateTime(targetDate.year, targetDate.month + 1, 0).day;
    if (_selectedDay > daysInCurrentMonth) {
      _selectedDay = daysInCurrentMonth;
    }

    final selectedDateTime = DateTime(
      targetDate.year,
      targetDate.month,
      _selectedDay,
    );

    return Scaffold(
      backgroundColor: currentAccount.palette.background,
      appBar: AppBar(
        backgroundColor: currentAccount.palette.background,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BetterText(text: 'Calendar', size: 30.0, colour: currentAccount.palette.textPrimary),
            const ProfileIconButton(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BetterText(
                  text: _isWeekView
                      ? "${currentMonday.day}–${currentSunday.day} ${getMonth(dateTime: currentSunday)} ${currentSunday.year}"
                      : "${getMonth(dateTime: targetDate)} ${targetDate.year}",
                  size: 18.0,
                  weight: 600,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isWeekView = !_isWeekView;
                        });
                      },
                      child: BetterText(
                        text: _isWeekView ? "Month" : "Week",
                        size: 14.0,
                        weight: 600,
                        colour: currentAccount.palette.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_isWeekView) {
                            _weekOffset -= 1;
                          } else {
                            _offset -= 1;
                            _selectedDay = 1;
                          }
                        });
                      },
                      icon: Icon(Icons.keyboard_arrow_left, color: currentAccount.palette.textPrimary),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_isWeekView) {
                            _weekOffset += 1;
                          } else {
                            _offset += 1;
                            _selectedDay = 1;
                          }
                        });
                      },
                      icon: Icon(Icons.keyboard_arrow_right, color: currentAccount.palette.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
            _isWeekView
                ? WeekCalendarView(
                    weekOffset: _weekOffset,
                    selectedDay: _selectedDay,
                    onDaySelected: (day) {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                  )
                : MonthCalendarView(
                    offset: _offset,
                    selectedDay: _selectedDay,
                    onDaySelected: (day) {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                  ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                BetterText(text: "● ", colour: currentAccount.palette.primary, size: 12.0),
                BetterText(text: "Booked appointment   ", size: 12.0, colour: currentAccount.palette.textSecondary),
                const BetterText(text: "○ ", size: 12.0),
                BetterText(text: "Open booking times", size: 12.0, colour: currentAccount.palette.textSecondary),
              ],
            ),
            const SizedBox(height: 20.0),
            BetterText(
              text: "${getWeekDay(dateTime: selectedDateTime)}, ${getMonth(dateTime: targetDate)} $_selectedDay",
              size: 20.0,
              weight: 600,
            ),
            const SizedBox(height: 4.0),
            BetterText(
              text: "Booking",
              size: 13.0,
              colour: currentAccount.palette.textSecondary,
            ),
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                border: Border.all(color: currentAccount.palette.smoke, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BetterText(text: "14:30", weight: 600, size: 14.0, colour: currentAccount.palette.textPrimary),
                      BetterText(text: "15:00", colour: currentAccount.palette.textSecondary, size: 14.0),
                    ],
                  ),
                  const VerticalDivider(width: 30),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BetterText(text: "Jamie Chen", weight: 600, size: 15.0, colour: currentAccount.palette.textPrimary),
                        const SizedBox(height: 2.0),
                        BetterText(
                          text: "Follow-up appointment - 30 min",
                          size: 12.0,
                          colour: currentAccount.palette.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_right, color: currentAccount.palette.textPrimary),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: currentAccount.palette.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const BetterText(
                  text: "Choose a time",
                  colour: Colors.white,
                  weight: 600,
                  size: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavigationFooter(),
    );
  }
}