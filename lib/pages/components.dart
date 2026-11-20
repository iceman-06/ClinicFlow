import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/pages/client/home_page.dart' as client_home;
import 'package:clinicflow/pages/client/calendar_page.dart' as client_calendar;
import 'package:clinicflow/pages/client/profiles_page.dart' as client_profiles;
import 'package:clinicflow/pages/client/settings_page.dart' as client_settings;
import 'package:clinicflow/pages/staff/home_page.dart' as staff_home;
import 'package:clinicflow/pages/staff/calendar_page.dart' as staff_calendar;
import 'package:clinicflow/pages/staff/profiles_page.dart' as staff_profiles;
import 'package:clinicflow/pages/staff/settings_page.dart' as staff_settings;

abstract final class Colours {
  static const Color green = Color.fromARGB(255, 16, 108, 103);
  static const Color eggWhite = Color.fromARGB(255, 224, 224, 224);
  static const Color thinGreen = Color.fromARGB(255, 230, 242, 238);
  static const Color lightSmoke = Color.fromARGB(255, 224, 224, 224);
}

class BetterText extends StatelessWidget {
  final String text;
  final double? size;
  final int? weight;
  final Color? colour;
  final TextAlign? align;

  const BetterText({
    super.key,
    required this.text,
    this.size,
    this.weight,
    this.colour,
    this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: colour ?? Colors.black,
        fontSize: size ?? 14.0,
        fontWeight: FontWeight(weight ?? 400),
      ),
      textAlign: align ?? TextAlign.start,
    );
  }
}

class NavigationFooter extends StatelessWidget {
  const NavigationFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isStaff = currentAccount.isStaff;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => isStaff
                      ? const staff_home.HomePage()
                      : const client_home.HomePage(),
                ),
              );
            },
            icon: const Icon(Icons.home, color: Colours.green),
            tooltip: "Home",
            iconSize: 40,
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => isStaff
                      ? const staff_calendar.CalendarPage()
                      : const client_calendar.CalendarPage(),
                ),
              );
            },
            icon: const Icon(Icons.calendar_month, color: Colours.green),
            tooltip: "Calendar",
            iconSize: 40,
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => isStaff
                      ? const staff_profiles.ProfilesPage()
                      : const client_profiles.ProfilesPage(),
                ),
              );
            },
            icon: const Icon(Icons.people, color: Colours.green),
            tooltip: "Profiles",
            iconSize: 40,
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => isStaff
                      ? const staff_settings.SettingsPage()
                      : const client_settings.SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings, color: Colours.green),
            tooltip: "Settings",
            iconSize: 40,
          ),
        ],
      ),
    );
  }
}

class SettingsSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const SettingsSectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BetterText(text: title, size: 18.0, weight: 600),
        if (subtitle != null) ...[
          const SizedBox(height: 2.0),
          BetterText(
            text: subtitle!,
            size: 13.0,
            colour: const Color.fromARGB(255, 120, 120, 120),
          ),
        ],
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String title;
  final String trailingText;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.title,
    required this.trailingText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BetterText(text: title, size: 15.0),
                BetterText(
                  text: trailingText,
                  size: 15.0,
                  colour: trailingText == "On" || trailingText == "Enabled"
                      ? Colors.black
                      : const Color.fromARGB(255, 120, 120, 120),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            const Divider(height: 1.0, thickness: 1.0, color: Colours.eggWhite),
          ],
        ),
      ),
    );
  }
}

class ThemeCard extends StatelessWidget {
  final String title;
  final String status;
  final bool isSelected;
  final Color primaryColor;
  final Color secondaryColor;
  final VoidCallback onTap;

  const ThemeCard({
    super.key,
    required this.title,
    required this.status,
    required this.isSelected,
    required this.primaryColor,
    required this.secondaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? Colours.green : Colours.lightSmoke,
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Container(
                    height: 6,
                    width: 40,
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            BetterText(text: title, weight: 600, size: 14.0),
            const SizedBox(height: 2.0),
            BetterText(
              text: status,
              size: 12.0,
              colour: isSelected
                  ? Colours.green
                  : const Color.fromARGB(255, 120, 120, 120),
            ),
          ],
        ),
      ),
    );
  }
}

String getWeekDay({bool truncate = false, DateTime? dateTime}) {
  dateTime ??= DateTime.now();
  if (truncate) {
    switch (dateTime.weekday) {
      case 1: return "Mon";
      case 2: return "Tue";
      case 3: return "Wed";
      case 4: return "Thu";
      case 5: return "Fri";
      case 6: return "Sat";
      case 7: return "Sun";
      default: return "Err";
    }
  } else {
    switch (dateTime.weekday) {
      case 1: return "Monday";
      case 2: return "Tuesday";
      case 3: return "Wednesday";
      case 4: return "Thursday";
      case 5: return "Friday";
      case 6: return "Saturday";
      case 7: return "Sunday";
      default: return "Error";
    }
  }
}

String getMonth({bool truncate = false, DateTime? dateTime}) {
  dateTime ??= DateTime.now();
  if (truncate) {
    switch (dateTime.month) {
      case 1: return "Jan";
      case 2: return "Feb";
      case 3: return "Mar";
      case 4: return "Apr";
      case 5: return "May";
      case 6: return "Jun";
      case 7: return "Jul";
      case 8: return "Aug";
      case 9: return "Sep";
      case 10: return "Oct";
      case 11: return "Nov";
      case 12: return "Dec";
      default: return "Err";
    }
  } else {
    switch (dateTime.month) {
      case 1: return "January";
      case 2: return "February";
      case 3: return "March";
      case 4: return "April";
      case 5: return "May";
      case 6: return "June";
      case 7: return "July";
      case 8: return "August";
      case 9: return "September";
      case 10: return "October";
      case 11: return "November";
      case 12: return "December";
      default: return "Error";
    }
  }
}

String getDay({bool suffix = false, DateTime? dateTime}) {
  dateTime ??= DateTime.now();
  if (suffix) {
    int day = dateTime.day;
    switch (day % 10) {
      case 1: return "${day}st";
      case 2: return "${day}nd";
      case 3: return "${day}rd";
      default: return "${day}th";
    }
  } else {
    return "${dateTime.day}";
  }
}

String getTime({TimeOfDay? timeOfDay}) {
  timeOfDay ??= TimeOfDay.now();
  return "${timeOfDay.hour}:${"${timeOfDay.minute}".padLeft(2, "0")}";
}