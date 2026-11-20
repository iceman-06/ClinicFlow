import 'package:clinicflow/main.dart';
import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/pages/components.dart';

class CalendarCell extends StatefulWidget {
  final int number;

  const CalendarCell({super.key, required this.number});

  @override
  State<CalendarCell> createState() => _CalendarCellState();
}

class _CalendarCellState extends State<CalendarCell> {
  bool _hasDot = false;
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        setState(() {
          _isActive = !_isActive;
        });
      },
      style: TextButton.styleFrom(foregroundColor: Colors.white, padding: EdgeInsets.all(0)),
      child: Container(
        alignment: AlignmentGeometry.center,
        color: _isActive ? Colours.green : Colors.white,
        child: BetterText(
          text: "${widget.number}${_hasDot ? "\n•" : ""}",
          colour: _isActive ? Colors.white : Colors.black,
          align: TextAlign.center,
        ),
      ),
    );
  }
}

class Calendar extends StatelessWidget {
  final int offset;
  const Calendar({super.key, required this.offset});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      primary: false,
      crossAxisCount: 7,
      mainAxisExtent: 40.0,
      shrinkWrap: true,
      children: <Widget>[
        Container(
          alignment: AlignmentGeometry.center,
          child: BetterText(text: "M"),
        ),
        Container(
          alignment: AlignmentGeometry.center,
          child: BetterText(text: "T"),
        ),
        Container(
          alignment: AlignmentGeometry.center,
          child: BetterText(text: "W"),
        ),
        Container(
          alignment: AlignmentGeometry.center,
          child: BetterText(text: "T"),
        ),
        Container(
          alignment: AlignmentGeometry.center,
          child: BetterText(text: "F"),
        ),
        Container(
          alignment: AlignmentGeometry.center,
          child: BetterText(text: "S"),
        ),
        Container(
          alignment: AlignmentGeometry.center,
          child: BetterText(text: "S"),
        ),
        for (var n = 0; n < 42; n++)
          CalendarCell(number: getCalendarNumber(n, offset)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BetterText(text: 'Calender', size: 30.0),
            CircleAvatar(backgroundColor: Colours.eggWhite, child: Text("JD")),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BetterText(
                        text:
                            "${getMonth(dateTime: DateTime(DateTime.now().year, DateTime.now().month + _offset))} ${DateTime(DateTime.now().year, DateTime.now().month + _offset).year}",
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
                              });
                            },
                            icon: Icon(Icons.keyboard_arrow_left),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _offset += 1;
                              });
                            },
                            icon: Icon(Icons.keyboard_arrow_right),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Calendar(offset: _offset),
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

int getCalendarNumber(int n, int offset) {
  DateTime now = DateTime(DateTime.now().year, DateTime.now().month + offset);
  int lastMonthLength = DateTime(now.year, now.month + offset, 0).day;
  return (n + lastMonthLength - DateTime(now.year, now.month, 1).weekday + 1) %
          (n < 7 ? lastMonthLength : DateTime(now.year, now.month + 1, 0).day) +
      1;
}
