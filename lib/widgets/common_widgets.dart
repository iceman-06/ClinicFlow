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
import 'package:clinicflow/main.dart';

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
        color: colour ?? currentAccount.palette.textPrimary,
        fontSize: size ?? 14.0,
        fontWeight: FontWeight(weight ?? 400),
      ),
      textAlign: align ?? TextAlign.start,
    );
  }
}

class ProfileIconButton extends StatelessWidget {
  const ProfileIconButton({super.key});

  void _showProfilePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: "Account Information", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BetterText(text: "Account Holder: ${currentAccount.name}", size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: "Selected Profile: ${currentAccount.activeProfile.name}", size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: "Client ID: ${currentAccount.activeProfile.clientId}", size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: "${currentAccount.t('account_type')}: ${currentAccount.isStaff ? currentAccount.t('clinic_staff_member') : 'Patient'}", size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: "Primary Email: ${currentAccount.primaryEmail}", size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: "Primary Phone: ${currentAccount.primaryPhone}", size: 14.0, colour: currentAccount.palette.textPrimary),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthPage()),
                (route) => false,
              );
            },
            child: BetterText(text: currentAccount.t('logout'), colour: Colors.red, weight: 600),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: BetterText(text: currentAccount.t('close'), colour: currentAccount.palette.primary, weight: 600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = currentAccount.palette;
    return GestureDetector(
      onTap: () => _showProfilePopup(context),
      child: CircleAvatar(
        backgroundColor: palette.secondary,
        child: Text(
          currentAccount.initials,
          style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class NavigationFooter extends StatelessWidget {
  final String currentPage;

  const NavigationFooter({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    final bool isStaff = currentAccount.isStaff;
    final palette = currentAccount.palette;

    bool isHome = currentPage == 'home';
    bool isCalendar = currentPage == 'calendar';
    bool isProfiles = currentPage == 'profiles';
    bool isSettings = currentPage == 'settings';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      decoration: BoxDecoration(
        color: palette.background,
        border: Border.all(
          color: palette.textPrimary,
          width: 2.0,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: isHome
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => isStaff
                            ? const staff_home.HomePage()
                            : const client_home.HomePage(),
                      ),
                    );
                  },
            icon: Icon(Icons.home, color: isHome ? palette.textSecondary : palette.primary),
            tooltip: currentAccount.t('home'),
            iconSize: 40,
          ),
          IconButton(
            onPressed: isCalendar
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => isStaff
                            ? const staff_calendar.CalendarPage()
                            : const client_calendar.CalendarPage(),
                      ),
                    );
                  },
            icon: Icon(Icons.calendar_month, color: isCalendar ? palette.textSecondary : palette.primary),
            tooltip: currentAccount.t('calendar'),
            iconSize: 40,
          ),
          IconButton(
            onPressed: isProfiles
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => isStaff
                            ? const staff_profiles.ProfilesPage()
                            : const client_profiles.ProfilesPage(),
                      ),
                    );
                  },
            icon: Icon(Icons.people, color: isProfiles ? palette.textSecondary : palette.primary),
            tooltip: currentAccount.t('profiles'),
            iconSize: 40,
          ),
          IconButton(
            onPressed: isSettings
                ? null
                : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => isStaff
                            ? const staff_settings.SettingsPage()
                            : const client_settings.SettingsPage(),
                      ),
                    );
                  },
            icon: Icon(Icons.settings, color: isSettings ? palette.textSecondary : palette.primary),
            tooltip: currentAccount.t('settings'),
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
            colour: currentAccount.palette.textSecondary,
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
                  colour: trailingText == "On" || trailingText == "Enabled" || trailingText == "English" || trailingText == "Français"
                      ? currentAccount.palette.textPrimary
                      : currentAccount.palette.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Divider(height: 1.0, thickness: 1.0, color: currentAccount.palette.smoke),
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
          color: currentAccount.palette.background,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? currentAccount.palette.primary : currentAccount.palette.smoke,
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
                  ? currentAccount.palette.primary
                  : currentAccount.palette.textSecondary,
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