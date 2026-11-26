import 'package:material_ui/material_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:url_launcher/url_launcher.dart';

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
        title: BetterText(text: currentAccount.t('account_information'), weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BetterText(text: currentAccount.t('account_holder_label', replacements: [currentAccount.name]), size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: currentAccount.t('selected_profile', replacements: [currentAccount.activeProfile.name]), size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: currentAccount.t('client_id', replacements: [currentAccount.activeProfile.clientId]), size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: "${currentAccount.t('account_type')}: ${currentAccount.isStaff ? currentAccount.t('clinic_staff_member') : 'Patient'}", size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: currentAccount.t('primary_email_value', replacements: [currentAccount.primaryEmail]), size: 14.0, colour: currentAccount.palette.textPrimary),
            const SizedBox(height: 6.0),
            BetterText(text: currentAccount.t('primary_phone_value', replacements: [currentAccount.primaryPhone]), size: 14.0, colour: currentAccount.palette.textPrimary),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
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
        backgroundColor: currentAccount.isStaff ? const Color(0xFF2867B2) : const Color(0xFF23866D),
        child: Text(
          currentAccount.initials,
          style: TextStyle(color: palette.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


class HelpMenuButton extends StatelessWidget {
  const HelpMenuButton({super.key});

  static const List<Map<String, String>> menuItems = [
    {
      'value': 'help',
      'label': 'help',
      'url': 'https://caiot.co',
    },
    {
      'value': 'feedback',
      'label': 'feedback',
      'url': 'https://forms.gle/7DEC4k6LXoJmNVrC8',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: currentAccount.t('help'),
      icon: Icon(
        Icons.arrow_drop_down,
        color: currentAccount.palette.textPrimary,
        size: 30,
      ),
      onSelected: (value) async {
        final item = menuItems.firstWhere(
          (item) => item['value'] == value,
        );

        final uri = Uri.parse(item['url']!);
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      },
      itemBuilder: (_) => menuItems.map((item) {
        return PopupMenuItem<String>(
          value: item['value'],
          child: Text(currentAccount.t(item['label']!)),
        );
      }).toList(),
    );
  }
}

void navigateBySwipe(BuildContext context, String currentPage, DragEndDetails details) {
  final velocity = details.primaryVelocity ?? 0;
  if (velocity.abs() < 250) return;
  const pages = ['home', 'calendar', 'profiles', 'settings'];
  final index = pages.indexOf(currentPage);
  final next = (index + (velocity < 0 ? 1 : -1)).clamp(0, pages.length - 1).toInt();
  if (next == index) return;
  final staff = currentAccount.isStaff;
  late final Widget page;
  if (pages[next] == 'home') {
    page = staff ? const staff_home.HomePage() : const client_home.HomePage();
  } else if (pages[next] == 'calendar') {
    page = staff ? const staff_calendar.CalendarPage() : const client_calendar.CalendarPage();
  } else if (pages[next] == 'profiles') {
    page = staff ? const staff_profiles.ProfilesPage() : const client_profiles.ProfilesPage();
  } else {
    page = staff ? const staff_settings.SettingsPage() : const client_settings.SettingsPage();
  }
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
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
      case 1: return currentAccount.t("mon");
      case 2: return currentAccount.t("tue");
      case 3: return currentAccount.t("wed");
      case 4: return currentAccount.t("thu");
      case 5: return currentAccount.t("fri");
      case 6: return currentAccount.t("sat");
      case 7: return currentAccount.t("sun");
      default: return "Err";
    }
  } else {
    switch (dateTime.weekday) {
      case 1: return currentAccount.t("monday");
      case 2: return currentAccount.t("tuesday");
      case 3: return currentAccount.t("wednesday");
      case 4: return currentAccount.t("thursday");
      case 5: return currentAccount.t("friday");
      case 6: return currentAccount.t("saturday");
      case 7: return currentAccount.t("sunday");
      default: return "Error";
    }
  }
}

String getMonth({bool truncate = false, DateTime? dateTime}) {
  dateTime ??= DateTime.now();
  if (truncate) {
    switch (dateTime.month) {
      case 1: return currentAccount.t("jan");
      case 2: return currentAccount.t("feb");
      case 3: return currentAccount.t("mar");
      case 4: return currentAccount.t("apr");
      case 5: return currentAccount.t("may");
      case 6: return currentAccount.t("jun");
      case 7: return currentAccount.t("jul");
      case 8: return currentAccount.t("aug");
      case 9: return currentAccount.t("sep");
      case 10: return currentAccount.t("oct");
      case 11: return currentAccount.t("nov");
      case 12: return currentAccount.t("dec");
      default: return "Err";
    }
  } else {
    switch (dateTime.month) {
      case 1: return currentAccount.t("january");
      case 2: return currentAccount.t("february");
      case 3: return currentAccount.t("march");
      case 4: return currentAccount.t("april");
      case 5: return currentAccount.t("may");
      case 6: return currentAccount.t("june");
      case 7: return currentAccount.t("july");
      case 8: return currentAccount.t("august");
      case 9: return currentAccount.t("september");
      case 10: return currentAccount.t("october");
      case 11: return currentAccount.t("november");
      case 12: return currentAccount.t("december");
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