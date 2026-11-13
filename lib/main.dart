import 'package:material_ui/material_ui.dart';

import 'package:clinicflow/pages/client/home_page.dart';

// Convert number to string
String getWeekDay({bool truncate = false, DateTime? dateTime}) {
  dateTime ??= DateTime.now();
  if (truncate) {
    switch (dateTime.weekday) {
      case 1:
        return "Mon";
      case 2:
        return "Tue";
      case 3:
        return "Wed";
      case 4:
        return "Thu";
      case 5:
        return "Fri";
      case 6:
        return "Sat";
      case 7:
        return "Sun";
      default:
        return "Err";
    }
  } else {
    switch (dateTime.weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "Error";
    }
  }
}

// Convert number to string
String getMonth({bool truncate = false, DateTime? dateTime}) {
  dateTime ??= DateTime.now();
  if (truncate) {
    switch (dateTime.month) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "Err";
    }
  } else {
    switch (dateTime.month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "Error";
    }
  }
}

// For consistancy
String getDay({bool suffix = false, DateTime? dateTime}) {
  dateTime ??= DateTime.now();
  if (suffix) {
    int day = dateTime.day;
    switch (day % 10) {
      case 1:
        return "${day}st";
      case 2:
        return "${day}nd";
      case 3:
        return "${day}rd";
      default:
        return "${day}th";
    }
  } else {
    return "${dateTime.day}";
  }
}

// Get the time in hh:mm format
String getTime({TimeOfDay? timeOfDay}) {
  timeOfDay ??= TimeOfDay.now();
  return "${timeOfDay.hour}:${"${timeOfDay.minute}".padLeft(2, "0")}";
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Page Stateful App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
