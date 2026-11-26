import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/models/translation.dart';
import 'package:clinicflow/services/firestore_service.dart';

const List<String> kStaffBookingTimeSlots = [
  "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00",
];

List<String> getAvailableStaffSlotsForDate(DateTime date) {
  final now = DateTime.now();
  return kStaffBookingTimeSlots.where((slot) {
    final parts = slot.split(':').map(int.parse).toList();
    final dt = DateTime(date.year, date.month, date.day, parts[0], parts[1]);
    return !dt.isBefore(now);
  }).toList();
}

class CalendarCell extends StatefulWidget {
  final int? dayNumber;
  final bool isSelected;
  final bool canSelect;
  final bool isPast;
  final bool hasAppointment;
  final VoidCallback? onTap;

  const CalendarCell({
    super.key,
    required this.dayNumber,
    required this.isSelected,
    required this.canSelect,
    required this.isPast,
    this.hasAppointment = false,
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
          text: "${widget.dayNumber}\n${widget.hasAppointment ? '●' : '○'}",
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
  final List<Appointment> appointments;

  const MonthCalendarView({
    super.key,
    required this.offset,
    required this.selectedDay,
    required this.onDaySelected,
    required this.appointments,
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

    final dayLabels = [
      currentAccount.t('day_m'),
      currentAccount.t('day_tu'),
      currentAccount.t('day_w'),
      currentAccount.t('day_th'),
      currentAccount.t('day_f'),
      currentAccount.t('day_sa'),
      currentAccount.t('day_su'),
    ];

    return GridView.count(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      primary: false,
      crossAxisCount: 7,
      mainAxisExtent: 40.0,
      shrinkWrap: true,
      children: <Widget>[
        for (String dayLabel in dayLabels)
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
              isPast: false,
              onTap: null,
            )
          else ...[
            () {
              final dayNum = n - leadingSpaces + 1;
              final cellDate = DateTime(year, month, dayNum);
              final isPast = cellDate.isBefore(DateTime(now.year, now.month, now.day));
              final hasAppt = appointments.any((a) =>
                  a.dateTime.year == year && a.dateTime.month == month && a.dateTime.day == dayNum);
              return CalendarCell(
                key: ValueKey('staff_cell_${year}_${month}_$dayNum'),
                dayNumber: dayNum,
                isSelected: selectedDay == dayNum,
                canSelect: true,
                isPast: isPast,
                hasAppointment: hasAppt,
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
  final List<Appointment> appointments;

  const WeekCalendarView({
    super.key,
    required this.selectedDateTime,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onSlotSelected,
    required this.selectedSlotTime,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final int weekday = selectedDateTime.weekday;
    final monday = selectedDateTime.subtract(Duration(days: weekday - 1));

    final weekDays = <Map<String, dynamic>>[];
    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      final name = getWeekDay(truncate: true, dateTime: d);
      final isPast = d.isBefore(DateTime(now.year, now.month, now.day));
      weekDays.add({"name": name, "date": d, "day": d.day, "isPast": isPast});
    }

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
              const SizedBox(width: 64),
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
              for (String hour in kStaffBookingTimeSlots)
                SizedBox(
                  height: 35,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        child: BetterText(
                          text: formatTimeString(hour),
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
                              final isBooked = appointments.any((a) =>
                                  a.dateTime.year == slotDate.year &&
                                  a.dateTime.month == slotDate.month &&
                                  a.dateTime.day == slotDate.day &&
                                  a.dateTime.hour == parts[0]);
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: currentAccount.palette.smoke,
                                    width: 0.5,
                                  ),
                                  color: isPastSlot
                                      ? currentAccount.palette.smoke.withAlpha(100)
                                      : isBooked
                                          ? currentAccount.palette.secondary
                                          : ((selectedDay == d["day"] && selectedSlotTime == hour)
                                              ? currentAccount.palette.primary
                                              : Colors.transparent),
                                ),
                                alignment: Alignment.center,
                                child: isBooked
                                    ? BetterText(
                                        text: "●",
                                        size: 10.0,
                                        colour: currentAccount.palette.primary,
                                        weight: 600,
                                      )
                                    : (selectedDay == d["day"] && selectedSlotTime == hour)
                                        ? BetterText(
                                            text: formatTimeString(hour),
                                            size: 9.0,
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
  String _selectedApptType = "follow_up";
  int _selectedApptLengthMinutes = 30;
  UserProfile? _selectedClientProfile;
  final TextEditingController _bookingReasonController = TextEditingController();
  final TextEditingController _bookingNotesController = TextEditingController();

  void _showBookingMenu(BuildContext context, DateTime date, String initialSlot, UserProfile targetProfile) {
    final availableSlots = getAvailableStaffSlotsForDate(date);
    if (availableSlots.isEmpty) return;

    _selectedApptType = AppLocalizations.appointmentTypeKeys.first;
    _selectedApptLengthMinutes = 30;
    String dialogSlot = availableSlots.contains(initialSlot) ? initialSlot : availableSlots.first;
    _bookingReasonController.clear();
    _bookingNotesController.clear();

    const lengthOptions = [15, 30, 45, 60, 0];

    String lengthLabel(int mins) {
      switch (mins) {
        case 15: return currentAccount.t('length_15');
        case 30: return currentAccount.t('length_30');
        case 45: return currentAccount.t('length_45');
        case 60: return currentAccount.t('length_60');
        default: return currentAccount.t('unknown_length');
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: currentAccount.palette.background,
          title: BetterText(text: currentAccount.t('book_appointment'), weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BetterText(text: currentAccount.t('profile_label', replacements: [targetProfile.name]), weight: 600, size: 15.0, colour: currentAccount.palette.primary),
                const SizedBox(height: 8.0),
                BetterText(
                  text: currentAccount.t('date_label', replacements: ["${getMonth(dateTime: date)} $_selectedDay, ${date.year}"]),
                  size: 14.0,
                  colour: currentAccount.palette.textPrimary,
                ),
                const SizedBox(height: 12.0),
                BetterText(text: currentAccount.t('time'), size: 13.0, weight: 600, colour: currentAccount.palette.textPrimary),
                DropdownButton<String>(
                  value: dialogSlot,
                  dropdownColor: currentAccount.palette.background,
                  isExpanded: true,
                  items: availableSlots
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: BetterText(text: formatTimeString(t), colour: currentAccount.palette.textPrimary),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        dialogSlot = val;
                      });
                      setState(() {
                        _selectedSlotTime = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12.0),
                BetterText(text: currentAccount.t('appointment_type'), size: 13.0, weight: 600, colour: currentAccount.palette.textPrimary),
                DropdownButton<String>(
                  value: _selectedApptType,
                  dropdownColor: currentAccount.palette.background,
                  isExpanded: true,
                  items: AppLocalizations.appointmentTypeKeys
                      .map((key) => DropdownMenuItem(
                            value: key,
                            child: BetterText(text: currentAccount.t(key), colour: currentAccount.palette.textPrimary),
                          ))
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
                DropdownButton<int>(
                  value: _selectedApptLengthMinutes,
                  dropdownColor: currentAccount.palette.background,
                  isExpanded: true,
                  items: lengthOptions
                      .map((mins) => DropdownMenuItem(
                            value: mins,
                            child: BetterText(text: lengthLabel(mins), colour: currentAccount.palette.textPrimary),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        _selectedApptLengthMinutes = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12.0),
                BetterText(text: currentAccount.t('appointment_reason'), size: 13.0, weight: 600, colour: currentAccount.palette.textPrimary),
                const SizedBox(height: 6.0),
                TextField(
                  controller: _bookingReasonController,
                  style: TextStyle(color: currentAccount.palette.textPrimary),
                  decoration: themedInputDecoration(
                    hintText: currentAccount.t('appointment_reason_hint'),
                  ),
                ),
                const SizedBox(height: 12.0),
                BetterText(text: currentAccount.t('notes_optional'), size: 13.0, weight: 600, colour: currentAccount.palette.textPrimary),
                const SizedBox(height: 6.0),
                TextField(
                  controller: _bookingNotesController,
                  minLines: 2,
                  maxLines: 4,
                  style: TextStyle(color: currentAccount.palette.textPrimary),
                  decoration: themedInputDecoration(
                    hintText: currentAccount.t('booking_notes_hint'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: BetterText(text: currentAccount.t('cancel'), colour: currentAccount.palette.primary),
            ),
            TextButton(
              onPressed: () async {
                final bookingReason = _bookingReasonController.text.trim();
                if (bookingReason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(currentAccount.t('error_reason_required'))),
                  );
                  return;
                }

                final bookingNotes = _bookingNotesController.text.trim();
                final slotParts = dialogSlot.split(':').map(int.parse).toList();
                final apptDateTime = DateTime(date.year, date.month, _selectedDay, slotParts[0], slotParts[1]);
                final ownerAccountId = targetProfile.accountId.isNotEmpty ? targetProfile.accountId : currentAccount.id;

                final newAppointment = Appointment(
                  id: '',
                  accountId: ownerAccountId,
                  profileId: targetProfile.id,
                  clientName: targetProfile.name,
                  dateTime: apptDateTime,
                  duration: Duration(minutes: _selectedApptLengthMinutes),
                  description: currentAccount.t(_selectedApptType),
                  reason: bookingReason,
                  status: 'Confirmed',
                  notes: bookingNotes,
                );

                Navigator.pop(ctx);
                await FirestoreService.createAppointment(newAppointment);

                if (bookingNotes.isNotEmpty) {
                  final existingNotes = targetProfile.notes.trim();
                  targetProfile.notes = existingNotes.isEmpty
                      ? bookingNotes
                      : '$existingNotes\nAppointment note: $bookingNotes';
                  await FirestoreService.saveProfile(ownerAccountId, targetProfile);
                }

                if (!context.mounted) return;
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
    _bookingReasonController.dispose();
    _bookingNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    final availableSlots = getAvailableStaffSlotsForDate(selectedDateTime);
    final effectiveSlotTime = availableSlots.isEmpty
        ? _selectedSlotTime
        : (availableSlots.contains(_selectedSlotTime) ? _selectedSlotTime : availableSlots.first);

    final bool isPastDate = selectedDateTime.isBefore(DateTime(now.year, now.month, now.day));
    final slotParts = effectiveSlotTime.split(':').map(int.parse).toList();
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
      body: StreamBuilder<List<Appointment>>(
        stream: FirestoreService.streamAllAppointments(),
        builder: (context, apptSnapshot) {
          final appointments = apptSnapshot.data ?? [];
          final dayAppointments = appointments.where((a) =>
              a.dateTime.year == selectedDateTime.year &&
              a.dateTime.month == selectedDateTime.month &&
              a.dateTime.day == selectedDateTime.day).toList();

          return StreamBuilder<List<UserProfile>>(
            stream: FirestoreService.streamAllProfilesForStaff(),
            builder: (context, profileSnapshot) {
              final allProfiles = (profileSnapshot.data != null && profileSnapshot.data!.isNotEmpty)
                  ? profileSnapshot.data!
                  : currentAccount.profiles;
              final targetProfile = _selectedClientProfile != null
                  ? allProfiles.firstWhere((p) => p.id == _selectedClientProfile!.id, orElse: () => currentAccount.activeProfile)
                  : currentAccount.activeProfile;

              return GestureDetector(
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
                              appointments: appointments,
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
                              selectedSlotTime: effectiveSlotTime,
                            )
                          : MonthCalendarView(
                              offset: _offset,
                              selectedDay: _selectedDay,
                              appointments: appointments,
                              onDaySelected: (day) {
                                setState(() {
                                  _selectedDay = day;
                                });
                              },
                            ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          BetterText(text: "● ", size: 12.0, colour: currentAccount.palette.primary),
                          BetterText(text: "${currentAccount.t('booked_appointment')}   ", size: 12.0, colour: currentAccount.palette.textSecondary),
                          BetterText(
                            text: "○ ",
                            size: 12.0,
                            colour: currentAccount.palette.textSecondary,
                          ),
                          BetterText(
                            text: currentAccount.t('thirty_min_openings'),
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
                      if (dayAppointments.isNotEmpty) ...[
                        const SizedBox(height: 8.0),
                        for (final appt in dayAppointments)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: currentAccount.palette.primary, width: 1.2),
                              borderRadius: BorderRadius.circular(10.0),
                              color: currentAccount.palette.secondary,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      BetterText(
                                        text: "${formatDateTimeTime(appt.dateTime)} • ${appt.clientName}",
                                        weight: 600,
                                        size: 14.0,
                                        colour: currentAccount.palette.textPrimary,
                                      ),
                                      BetterText(
                                        text: "${currentAccount.translateAppointmentType(appt.description)} (${appt.formattedDuration}) · ${currentAccount.translateStatus(appt.status)}",
                                        size: 12.0,
                                        colour: currentAccount.palette.textSecondary,
                                      ),
                                      if (appt.reason.isNotEmpty)
                                        BetterText(
                                          text: currentAccount.t('reason_label', replacements: [appt.reason]),
                                          size: 12.0,
                                          colour: currentAccount.palette.textSecondary,
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    await FirestoreService.cancelAppointment(appt.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(currentAccount.t('appointment_cancelled'))),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                      const SizedBox(height: 4.0),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: currentAccount.palette.smoke, width: 1.5),
                          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Row(
                          children: [
                            PopupMenuButton<String>(
                              color: currentAccount.palette.background,
                              enabled: availableSlots.isNotEmpty,
                              tooltip: currentAccount.t('select_time'),
                              onSelected: (timeVal) {
                                setState(() {
                                  _selectedSlotTime = timeVal;
                                });
                              },
                              itemBuilder: (_) => availableSlots
                                  .map((t) => PopupMenuItem<String>(
                                        value: t,
                                        child: Text(
                                          formatTimeString(t),
                                          style: TextStyle(color: currentAccount.palette.textPrimary),
                                        ),
                                      ))
                                  .toList(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BetterText(
                                    text: availableSlots.isEmpty
                                        ? "--"
                                        : formatTimeString(effectiveSlotTime),
                                    weight: 600,
                                    size: 14.0,
                                    colour: currentAccount.palette.textPrimary,
                                  ),
                                  const SizedBox(width: 2.0),
                                  Icon(Icons.arrow_drop_down, color: currentAccount.palette.textPrimary),
                                ],
                              ),
                            ),
                            const VerticalDivider(width: 20),
                            Expanded(
                              child: BetterText(
                                text: availableSlots.isEmpty
                                    ? currentAccount.t('no_times_available')
                                    : "${targetProfile.name} · ${currentAccount.t('selected_opening_slot')}",
                                size: 13.0,
                                colour: availableSlots.isEmpty ? Colors.red : currentAccount.palette.textSecondary,
                              ),
                            ),
                            PopupMenuButton<UserProfile>(
                              color: currentAccount.palette.background,
                              icon: Icon(Icons.keyboard_arrow_right, color: currentAccount.palette.textPrimary),
                              tooltip: currentAccount.t('change_profile'),
                              onSelected: (profile) => setState(() => _selectedClientProfile = profile),
                              itemBuilder: (_) => allProfiles.map((profile) => PopupMenuItem<UserProfile>(
                                value: profile,
                                child: Text(
                                  profile.name,
                                  style: TextStyle(color: currentAccount.palette.textPrimary),
                                ),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: (isPastDate || isPastSlot || availableSlots.isEmpty)
                              ? null
                              : () => _showBookingMenu(context, selectedDateTime, effectiveSlotTime, targetProfile),
                          style: FilledButton.styleFrom(
                            backgroundColor: (isPastDate || isPastSlot || availableSlots.isEmpty)
                                ? Colors.grey
                                : currentAccount.palette.primary,
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
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const NavigationFooter(currentPage: 'calendar'),
    );
  }
}