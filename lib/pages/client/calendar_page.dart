import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/models/translation.dart';
import 'package:clinicflow/services/firestore_service.dart';

const List<String> kBookingTimeSlots = [
  "09:00", "10:00", "11:00", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00",
];

List<String> getAvailableBookingSlotsForDate(DateTime date) {
  final now = DateTime.now();
  return kBookingTimeSlots.where((slot) {
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
        color: widget.isSelected ? currentAccount.palette.primary : currentAccount.palette.background,
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
  final List<BookedSlot> bookedSlots;

  const MonthCalendarView({
    super.key,
    required this.offset,
    required this.selectedDay,
    required this.onDaySelected,
    required this.bookedSlots,
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
              final hasAppt = bookedSlots.any((s) =>
                  s.dateTime.year == year && s.dateTime.month == month && s.dateTime.day == dayNum);
              return CalendarCell(
                key: ValueKey('client_cell_${year}_${month}_$dayNum'),
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

class ChooseTimeSection extends StatefulWidget {
  final DateTime selectedDate;
  final String? initialSlot;
  final List<BookedSlot> bookedSlots;
  final List<String> openSlots;

  const ChooseTimeSection({
    super.key,
    required this.selectedDate,
    this.initialSlot,
    required this.bookedSlots,
    required this.openSlots,
  });

  @override
  State<ChooseTimeSection> createState() => _ChooseTimeSectionState();
}

class _ChooseTimeSectionState extends State<ChooseTimeSection> {
  String? _selectedSlot;
  late String _visitPurpose;
  final int _durationMinutes = 30;
  bool _isSubmitting = false;

  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _visitPurpose = AppLocalizations.appointmentTypeKeys.first;
    _syncSlot();
  }

  @override
  void didUpdateWidget(covariant ChooseTimeSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.initialSlot != widget.initialSlot ||
        oldWidget.openSlots != widget.openSlots) {
      _syncSlot();
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _syncSlot() {
    if (widget.openSlots.isEmpty) {
      _selectedSlot = null;
    } else if (widget.initialSlot != null && widget.openSlots.contains(widget.initialSlot)) {
      _selectedSlot = widget.initialSlot;
    } else if (_selectedSlot == null || !widget.openSlots.contains(_selectedSlot)) {
      _selectedSlot = widget.openSlots.first;
    }
  }

  String _formatEndTime(String startSlot, int mins) {
    final parts = startSlot.split(':').map(int.parse).toList();
    final total = parts[0] * 60 + parts[1] + mins;
    final h = (total ~/ 60) % 24;
    final m = total % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  Future<void> _submitBooking() async {
    if (_selectedSlot == null || _isSubmitting) return;
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentAccount.t('error_reason_required'))),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final parts = _selectedSlot!.split(':').map(int.parse).toList();
      final apptDateTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        parts[0],
        parts[1],
      );
      final notes = _notesController.text.trim();

      await FirestoreService.createAppointment(
        Appointment(
          id: '',
          accountId: currentAccount.id,
          profileId: currentAccount.activeProfile.id,
          clientName: currentAccount.activeProfile.name,
          dateTime: apptDateTime,
          duration: Duration(minutes: _durationMinutes),
          description: currentAccount.t(_visitPurpose),
          reason: reason,
          status: 'Upcoming',
          notes: notes,
        ),
      );

      if (notes.isNotEmpty) {
        final existing = currentAccount.activeProfile.notes.trim();
        currentAccount.activeProfile.notes = existing.isEmpty
            ? notes
            : '$existing\nAppointment note: $notes';
        await FirestoreService.saveProfile(currentAccount.id, currentAccount.activeProfile);
      }

      if (!mounted) return;
      _reasonController.clear();
      _notesController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentAccount.t('appointment_booked'))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = currentAccount.palette;
    final monday = widget.selectedDate.subtract(Duration(days: widget.selectedDate.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 28),

        // 7-day strip around selected date
        Row(
          children: [
            for (final day in weekDays) ...[
              () {
                final selected = day.year == widget.selectedDate.year &&
                    day.month == widget.selectedDate.month &&
                    day.day == widget.selectedDate.day;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? palette.primary : palette.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? palette.primary : palette.smoke,
                        ),
                      ),
                      child: Column(
                        children: [
                          BetterText(
                            text: getWeekDay(truncate: true, dateTime: day),
                            size: 11.0,
                            colour: selected ? Colors.white70 : palette.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          BetterText(
                            text: '${day.day}',
                            size: 15.0,
                            weight: 600,
                            colour: selected ? Colors.white : palette.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }(),
            ],
          ],
        ),
        const SizedBox(height: 14),

        // Profile & duration banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BetterText(
                text: currentAccount.t(_visitPurpose),
                size: 15.0,
                weight: 600,
                colour: palette.textPrimary,
              ),
              const SizedBox(height: 2),
              BetterText(
                text: '${currentAccount.activeProfile.name} · $_durationMinutes minutes',
                size: 13.0,
                colour: palette.textSecondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Visit purpose dropdown + reason/notes
        BetterText(
          text: currentAccount.t('appointment_type'),
          size: 13.0,
          weight: 600,
          colour: palette.textPrimary,
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _visitPurpose,
          dropdownColor: palette.background,
          decoration: themedInputDecoration(),
          items: AppLocalizations.appointmentTypeKeys
              .map(
                (key) => DropdownMenuItem(
                  value: key,
                  child: BetterText(text: currentAccount.t(key), colour: palette.textPrimary),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _visitPurpose = val);
          },
        ),
        const SizedBox(height: 12),
        BetterText(
          text: currentAccount.t('appointment_reason'),
          size: 13.0,
          weight: 600,
          colour: palette.textPrimary,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _reasonController,
          style: TextStyle(color: palette.textPrimary),
          decoration: themedInputDecoration(hintText: currentAccount.t('appointment_reason_hint')),
        ),
        const SizedBox(height: 12),
        BetterText(
          text: currentAccount.t('notes_optional'),
          size: 13.0,
          weight: 600,
          colour: palette.textPrimary,
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _notesController,
          minLines: 2,
          maxLines: 3,
          style: TextStyle(color: palette.textPrimary),
          decoration: themedInputDecoration(hintText: currentAccount.t('booking_notes_hint')),
        ),
        const SizedBox(height: 18),

        BetterText(
          text: 'Available times',
          size: 18.0,
          weight: 700,
          colour: palette.textPrimary,
        ),
        BetterText(
          text: 'Select one time block. Times are local.',
          size: 13.0,
          colour: palette.textSecondary,
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.openSlots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.35,
          ),
          itemBuilder: (context, index) {
            final slot = widget.openSlots[index];
            final isSelected = _selectedSlot == slot;
            return OutlinedButton(
              onPressed: () => setState(() => _selectedSlot = slot),
              style: OutlinedButton.styleFrom(
                backgroundColor: isSelected ? palette.primary : palette.background,
                side: BorderSide(
                  color: isSelected ? palette.primary : palette.smoke,
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: BetterText(
                text: slot,
                size: 15.0,
                weight: 600,
                colour: isSelected ? Colors.white : palette.textPrimary,
              ),
            );
          },
        ),
        if (_selectedSlot != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: palette.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: BetterText(
              text: 'Selected: $_selectedSlot–${_formatEndTime(_selectedSlot!, _durationMinutes)}',
              size: 14.0,
              weight: 600,
              colour: palette.primary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submitBooking,
              style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: BetterText(
                text: 'Continue · $_selectedSlot',
                size: 15.0,
                weight: 600,
                colour: Colors.white,
              ),
            ),
          ),
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
  int _selectedDay = DateTime.now().day;
  String _selectedSlotTime = "09:00";

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final targetDate = DateTime(
      now.year,
      now.month + _offset,
      1,
    );

    final daysInCurrentMonth = DateTime(targetDate.year, targetDate.month + 1, 0).day;
    if (_selectedDay > daysInCurrentMonth) {
      _selectedDay = daysInCurrentMonth;
    }

    final selectedDateTime = DateTime(targetDate.year, targetDate.month, _selectedDay);

    final availableSlots = getAvailableBookingSlotsForDate(selectedDateTime);
    final effectiveSlotTime = availableSlots.isEmpty
        ? _selectedSlotTime
        : (availableSlots.contains(_selectedSlotTime) ? _selectedSlotTime : availableSlots.first);

    final bool isPastDate = selectedDateTime.isBefore(DateTime(now.year, now.month, now.day));
    final slotParts = effectiveSlotTime.split(':').map(int.parse).toList();
    final selectedSlotStart = DateTime(
      selectedDateTime.year,
      selectedDateTime.month,
      selectedDateTime.day,
      slotParts[0],
      slotParts[1],
    );
    final bool isPastSlot = selectedSlotStart.isBefore(now);

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
      body: StreamBuilder<List<BookedSlot>>(
        stream: FirestoreService.streamBookedSlots(),
        builder: (context, slotsSnapshot) {
          final bookedSlots = slotsSnapshot.data ?? [];
          final bool isTakenSlot = bookedSlots.any((s) => s.overlaps(selectedSlotStart, const Duration(minutes: 60)));

          final openSlotsForDay = availableSlots.where((slot) {
            final parts = slot.split(':').map(int.parse).toList();
            final start = DateTime(
              selectedDateTime.year,
              selectedDateTime.month,
              selectedDateTime.day,
              parts[0],
              parts[1],
            );
            return !bookedSlots.any((s) => s.overlaps(start, const Duration(minutes: 30)));
          }).toList();
          final bool showChooseTimeSection = !isPastDate && openSlotsForDay.isNotEmpty;

          return StreamBuilder<List<Appointment>>(
            stream: FirestoreService.streamAccountAppointments(currentAccount.id),
            builder: (context, snapshot) {
              final appointments = snapshot.data ?? [];
              final dayAppointments = appointments.where((a) =>
                  a.dateTime.year == selectedDateTime.year &&
                  a.dateTime.month == selectedDateTime.month &&
                  a.dateTime.day == selectedDateTime.day).toList();

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
                            text: "${getMonth(dateTime: targetDate)} ${targetDate.year}",
                            size: 18.0,
                            weight: 600,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _offset -= 1;
                                    _selectedDay = 1;
                                  });
                                },
                                icon: Icon(Icons.keyboard_arrow_left, color: currentAccount.palette.textPrimary),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _offset += 1;
                                    _selectedDay = 1;
                                  });
                                },
                                icon: Icon(Icons.keyboard_arrow_right, color: currentAccount.palette.textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      MonthCalendarView(
                        offset: _offset,
                        selectedDay: _selectedDay,
                        bookedSlots: bookedSlots,
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
                          BetterText(text: "○ ", size: 12.0),
                          BetterText(text: currentAccount.t('open_booking_times'), size: 12.0, colour: currentAccount.palette.textSecondary),
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
                                      SnackBar(content: Text(currentAccount.t('appointment_cancelled_success'))),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                      const SizedBox(height: 4.0),
                      BetterText(
                        text: availableSlots.isEmpty
                            ? currentAccount.t('no_times_available')
                            : (isTakenSlot
                                ? currentAccount.t('slot_already_taken', replacements: [formatTimeString(effectiveSlotTime)])
                                : currentAccount.t('selected_opening_slot')),
                        size: 13.0,
                        colour: (isTakenSlot || availableSlots.isEmpty) ? Colors.red : currentAccount.palette.textSecondary,
                      ),
                      if (isTakenSlot && !isPastDate && !isPastSlot && availableSlots.isNotEmpty) ...[
                        const SizedBox(height: 16.0),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await FirestoreService.joinWaitlist(
                                WaitlistEntry(
                                  id: '',
                                  accountId: currentAccount.id,
                                  profileId: currentAccount.activeProfile.id,
                                  clientName: currentAccount.activeProfile.name,
                                  preferredDateTime: selectedSlotStart,
                                  appointmentType: currentAccount.t('follow_up'),
                                ),
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(currentAccount.t('waitlist_joined'))),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: currentAccount.palette.primary, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            icon: Icon(Icons.hourglass_top, color: currentAccount.palette.primary),
                            label: BetterText(
                              text: currentAccount.t('join_waitlist'),
                              colour: currentAccount.palette.primary,
                              weight: 600,
                              size: 16.0,
                            ),
                          ),
                        ),
                      ],
                      if (showChooseTimeSection)
                        ChooseTimeSection(
                          selectedDate: selectedDateTime,
                          initialSlot: openSlotsForDay.contains(effectiveSlotTime)
                              ? effectiveSlotTime
                              : openSlotsForDay.first,
                          bookedSlots: bookedSlots,
                          openSlots: openSlotsForDay,
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