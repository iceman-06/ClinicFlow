import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';

class CalendarCell extends StatefulWidget {
  final int? dayNumber;
  final bool isSelected;
  final bool canSelect;
  final bool isPast;
  final VoidCallback? onTap;

  const CalendarCell({
    super.key,
    required this.dayNumber,
    required this.isSelected,
    required this.canSelect,
    required this.isPast,
    required this.onTap,
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

    Color textColor = widget.canSelect
        ? (widget.isSelected ? Colors.white : currentAccount.palette.textPrimary)
        : currentAccount.palette.textSecondary;

    if (widget.isPast && !widget.isSelected) {
      textColor = textColor.withAlpha(120);
    }

    return TextButton(
      onPressed: widget.canSelect ? widget.onTap : null,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: EdgeInsets.zero,
      ),
      child: Container(
        alignment: Alignment.center,
        color: widget.isSelected
            ? currentAccount.palette.primary
            : currentAccount.palette.background,
        child: BetterText(
          text: "${widget.dayNumber}\n○",
          colour: textColor,
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
            CalendarCell(
              dayNumber: null,
              isSelected: false,
              canSelect: false,
              isPast: false,
              onTap: null,
            )
          else ...[
            () {
              final dayNum = n - leadingSpaces + 1;
              final cellDate = DateTime(year, month, dayNum);
              final isPast = cellDate.isBefore(DateTime(now.year, now.month, now.day));
              return CalendarCell(
                key: ValueKey('staff_cell_${year}_${month}_$dayNum'),
                dayNumber: dayNum,
                isSelected: selectedDay == dayNum,
                canSelect: true,
                isPast: isPast,
                onTap: () => onDaySelected(dayNum),
              );
            }()
          ]
        ],
      ],
    );
  }
}

class WeekCalendarView extends StatelessWidget {
  final DateTime selectedDateTime;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;
  final Function(DateTime, String) onSlotSelected;
  final String selectedSlotTime;

  const WeekCalendarView({
    super.key,
    required this.selectedDateTime,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onSlotSelected,
    required this.selectedSlotTime,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final int weekday = selectedDateTime.weekday;
    final monday = selectedDateTime.subtract(Duration(days: weekday - 1));

    final weekDays = [];
    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
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
      final isPast = d.isBefore(DateTime(now.year, now.month, now.day));
      weekDays.add({"name": name, "date": d, "day": d.day, "isPast": isPast});
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
                          colour: selectedDay == d["day"]
                              ? currentAccount.palette.primary
                              : (d["isPast"] == true ? currentAccount.palette.textSecondary.withAlpha(120) : currentAccount.palette.textPrimary),
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
                            onTap: () {
                              final slotDate = d["date"] as DateTime;
                              final parts = hour.split(':').map(int.parse).toList();
                              final slotDateTime = DateTime(slotDate.year, slotDate.month, slotDate.day, parts[0], parts[1]);
                              if (slotDateTime.isBefore(DateTime.now())) return;
                              onDaySelected(d["day"] as int);
                              onSlotSelected(slotDate, hour);
                            },
                            child: Builder(builder: (context) {
                              final slotDate = d["date"] as DateTime;
                              final parts = hour.split(':').map(int.parse).toList();
                              final isPastSlot = DateTime(slotDate.year, slotDate.month, slotDate.day, parts[0], parts[1]).isBefore(DateTime.now());
                              return Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: currentAccount.palette.smoke,
                                  width: 0.5,
                                ),
                                color: isPastSlot
                                    ? currentAccount.palette.smoke.withAlpha(100)
                                    : ((selectedDay == d["day"] && selectedSlotTime == hour)
                                        ? currentAccount.palette.primary
                                        : Colors.transparent),
                              ),
                              alignment: Alignment.center,
                              child: (selectedDay == d["day"] && selectedSlotTime == hour)
                                  ? BetterText(
                                      text: hour,
                                      size: 10.0,
                                      colour: isPastSlot ? currentAccount.palette.textSecondary : Colors.white,
                                      weight: 600,
                                    )
                                  : const SizedBox.shrink(),
                            );
                            }),
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
  int _selectedDay = DateTime.now().day;
  bool _isWeekView = true;
  DateTime _currentWeekBase = DateTime.now();
  String _selectedSlotTime = "09:00";
  String _selectedApptType = "Follow-up";
  String _selectedApptLength = "30 minutes";
  final TextEditingController _bookingNotesController = TextEditingController();

  void _showBookingMenu(BuildContext context, DateTime date, String slot) {
    _selectedApptType = currentAccount.t('follow_up');
    _selectedApptLength = "30 minutes";
    _bookingNotesController.clear();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: currentAccount.palette.background,
          title: BetterText(text: currentAccount.t('book_appointment'), weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BetterText(text: currentAccount.t('profile_label', replacements: [currentAccount.activeProfile.name]), weight: 600, size: 15.0, colour: currentAccount.palette.primary),
              const SizedBox(height: 8.0),
              BetterText(text: currentAccount.t('date_label', replacements: ["${getMonth(dateTime: date)} $_selectedDay, ${date.year} à $slot"]), size: 14.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 12.0),
              BetterText(text: currentAccount.t('appointment_type'), size: 13.0, weight: 600, colour: currentAccount.palette.textPrimary),
              DropdownButton<String>(
                value: _selectedApptType,
                dropdownColor: currentAccount.palette.background,
                isExpanded: true,
                items: [currentAccount.t('follow_up'), currentAccount.t('initial_consultation'), currentAccount.t('specialist_consultation')]
                    .map((t) => DropdownMenuItem(value: t, child: BetterText(text: t, colour: currentAccount.palette.textPrimary)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      _selectedApptType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 12.0),
              BetterText(text: currentAccount.t('appointment_length'), size: 13.0, weight: 600, colour: currentAccount.palette.textPrimary),
              DropdownButton<String>(
                value: _selectedApptLength,
                dropdownColor: currentAccount.palette.background,
                isExpanded: true,
                items: ["30 minutes", "45 minutes", "60 minutes"]
                    .map((l) => DropdownMenuItem(value: l, child: BetterText(text: l, colour: currentAccount.palette.textPrimary)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      _selectedApptLength = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 12.0),
              BetterText(text: currentAccount.t('notes'), size: 13.0, weight: 600, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 6.0),
              TextField(
                controller: _bookingNotesController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: currentAccount.t('booking_notes_hint'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: BetterText(text: currentAccount.t('cancel'), colour: currentAccount.palette.primary),
            ),
            TextButton(
              onPressed: () {
                final bookingNotes = _bookingNotesController.text.trim();
                if (bookingNotes.isNotEmpty) {
                  final existingNotes = currentAccount.activeProfile.notes.trim();
                  currentAccount.activeProfile.notes = existingNotes.isEmpty
                      ? bookingNotes
                      : '$existingNotes\nAppointment note: $bookingNotes';
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(currentAccount.t('appointment_booked'))),
                );
              },
              child: BetterText(text: currentAccount.t('book'), colour: currentAccount.palette.primary, weight: 600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bookingNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    final now = DateTime.now();
    final targetDate = DateTime(
      now.year,
      now.month + _offset,
      1,
    );

    final daysInCurrentMonth = DateTime(
      targetDate.year,
      targetDate.month + 1,
      0,
    ).day;
    if (_selectedDay > daysInCurrentMonth) {
      _selectedDay = daysInCurrentMonth;
    }

    final selectedDateTime = _isWeekView
        ? _currentWeekBase.add(Duration(days: _selectedDay - _currentWeekBase.day))
        : DateTime(targetDate.year, targetDate.month, _selectedDay);

    final bool isPastDate = selectedDateTime.isBefore(DateTime(now.year, now.month, now.day));
    final slotParts = _selectedSlotTime.split(':').map(int.parse).toList();
    final bool isPastSlot = DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, slotParts[0], slotParts[1]).isBefore(now);

    final weekMonday = selectedDateTime.subtract(Duration(days: selectedDateTime.weekday - 1));
    final weekSunday = weekMonday.add(const Duration(days: 6));

    return Scaffold(
      backgroundColor: currentAccount.palette.background,
      appBar: AppBar(
        backgroundColor: currentAccount.palette.background,
        centerTitle: true,
        leadingWidth: 56,
        leading: const HelpMenuButton(),
        title: BetterText(text: currentAccount.t('calendar'), size: 24.0, colour: currentAccount.palette.textPrimary),
        actions: const [Padding(padding: EdgeInsets.only(right: 12.0), child: ProfileIconButton())],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) => navigateBySwipe(context, 'calendar', details),
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BetterText(
                  text: _isWeekView
                      ? "${weekMonday.day}–${weekSunday.day} ${getMonth(dateTime: weekSunday)} ${weekSunday.year}"
                      : "${getMonth(dateTime: targetDate)} ${targetDate.year}",
                  size: 18.0,
                  weight: 600,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        side: BorderSide(color: currentAccount.palette.primary, width: 1.3),
                        backgroundColor: currentAccount.palette.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                      onPressed: () {
                        setState(() {
                          if (!_isWeekView) {
                            _currentWeekBase = DateTime(targetDate.year, targetDate.month, _selectedDay);
                          } else {
                            _offset = _currentWeekBase.month - now.month;
                            _selectedDay = _currentWeekBase.day;
                          }
                          _isWeekView = !_isWeekView;
                        });
                      },
                      child: BetterText(
                        text: _isWeekView ? currentAccount.t('month') : currentAccount.t('week'),
                        size: 14.0,
                        weight: 600,
                        colour: currentAccount.palette.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_isWeekView) {
                            _currentWeekBase = _currentWeekBase.subtract(const Duration(days: 7));
                            _selectedDay = _currentWeekBase.day;
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
                            _currentWeekBase = _currentWeekBase.add(const Duration(days: 7));
                            _selectedDay = _currentWeekBase.day;
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
                    selectedDateTime: selectedDateTime,
                    selectedDay: _selectedDay,
                    onDaySelected: (day) {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                    onSlotSelected: (date, slot) {
                      setState(() {
                        _selectedSlotTime = slot;
                        _currentWeekBase = date;
                      });
                    },
                    selectedSlotTime: _selectedSlotTime,
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
                BetterText(
                  text: "○ ",
                  size: 12.0,
                  colour: currentAccount.palette.textSecondary,
                ),
                BetterText(
                  text: "30-minute openings",
                  size: 12.0,
                  colour: currentAccount.palette.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            BetterText(
              text: "${getWeekDay(dateTime: selectedDateTime)}, ${getMonth(dateTime: selectedDateTime)} $_selectedDay",
              size: 20.0,
              weight: 600,
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                Expanded(
                  child: BetterText(
                    text: "$_selectedSlotTime · ${currentAccount.activeProfile.name} · ${currentAccount.t('selected_opening_slot')}",
                    size: 13.0,
                    colour: currentAccount.palette.textSecondary,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.keyboard_arrow_right, color: currentAccount.palette.textPrimary),
                  tooltip: currentAccount.t('change_profile'),
                  onSelected: (profileId) => setState(() => currentAccount.activeProfileId = profileId),
                  itemBuilder: (_) => currentAccount.profiles.map((profile) => PopupMenuItem<String>(
                    value: profile.id, child: Text(profile.name),
                  )).toList(),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (isPastDate || isPastSlot) ? null : () => _showBookingMenu(context, selectedDateTime, _selectedSlotTime),
                style: FilledButton.styleFrom(
                  backgroundColor: (isPastDate || isPastSlot) ? Colors.grey : currentAccount.palette.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: BetterText(
                  text: currentAccount.t('book_this_time'),
                  colour: Colors.white,
                  weight: 600,
                  size: 16.0,
                ),
              ),
            ),
          ],
        ),
      )),
      bottomNavigationBar: const NavigationFooter(currentPage: 'calendar'),
    );
  }
}