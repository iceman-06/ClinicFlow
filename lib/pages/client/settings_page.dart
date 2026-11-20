import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/pages/components.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/pages/staff/settings_page.dart' as staff_settings;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _switchRole() {
    setState(() {
      currentAccount.toggleRole();
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => currentAccount.isStaff
            ? const staff_settings.SettingsPage()
            : const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BetterText(text: 'Settings', size: 30.0),
            CircleAvatar(
              backgroundColor: Colours.eggWhite,
              child: Text(currentAccount.initials),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionHeader(title: "Your account"),
            const SizedBox(height: 4.0),
            BetterText(
              text:
                  "${currentAccount.name} · ${currentAccount.profiles.length} registered family members",
              size: 13.0,
              colour: const Color.fromARGB(255, 100, 100, 100),
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _switchRole,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  side: const BorderSide(color: Colours.green, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: const Icon(Icons.swap_horiz, color: Colours.green),
                label: const BetterText(
                  text: "Switch to Staff View",
                  colour: Colours.green,
                  weight: 600,
                  size: 14.0,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            const SettingsSectionHeader(title: "Appointment preferences"),
            const SizedBox(height: 8.0),
            SettingsTile(
              title: "Email reminders",
              trailingText: currentAccount.emailReminders ? "On" : "Off",
              onTap: () {
                setState(() {
                  currentAccount.emailReminders =
                      !currentAccount.emailReminders;
                });
              },
            ),
            SettingsTile(
              title: "SMS reminders",
              trailingText: currentAccount.smsReminders ? "On" : "Off",
              onTap: () {
                setState(() {
                  currentAccount.smsReminders = !currentAccount.smsReminders;
                });
              },
            ),
            SettingsTile(
              title: "Virtual check-in",
              trailingText: currentAccount.virtualCheckInEnabled
                  ? "Enabled"
                  : "Disabled",
              onTap: () {
                setState(() {
                  currentAccount.virtualCheckInEnabled =
                      !currentAccount.virtualCheckInEnabled;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const SettingsSectionHeader(title: "Account details"),
            const SizedBox(height: 8.0),
            SettingsTile(
              title: "Family profiles",
              trailingText: "${currentAccount.profiles.length} members",
              onTap: () {},
            ),
            SettingsTile(
              title: "Contact details",
              trailingText: "Manage",
              onTap: () {},
            ),
            SettingsTile(
              title: "Privacy",
              trailingText: "Review",
              onTap: () {},
            ),
            const SizedBox(height: 20.0),
            const SettingsSectionHeader(
              title: "Color theme",
              subtitle: "A little color for your everyday care.",
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ThemeCard(
                  title: "Coastal",
                  status: currentAccount.theme == "Coastal"
                      ? "Selected"
                      : "Choose",
                  isSelected: currentAccount.theme == "Coastal",
                  primaryColor: const Color.fromARGB(255, 16, 108, 103),
                  secondaryColor: const Color.fromARGB(255, 230, 242, 238),
                  onTap: () {
                    setState(() {
                      currentAccount.theme = "Coastal";
                    });
                  },
                ),
                ThemeCard(
                  title: "Dark",
                  status: currentAccount.theme == "Dark"
                      ? "Selected"
                      : "Choose",
                  isSelected: currentAccount.theme == "Dark",
                  primaryColor: const Color.fromARGB(255, 60, 60, 60),
                  secondaryColor: const Color.fromARGB(255, 200, 200, 200),
                  onTap: () {
                    setState(() {
                      currentAccount.theme = "Dark";
                    });
                  },
                ),
                ThemeCard(
                  title: "Clay",
                  status: currentAccount.theme == "Clay"
                      ? "Selected"
                      : "Choose",
                  isSelected: currentAccount.theme == "Clay",
                  primaryColor: const Color.fromARGB(255, 160, 78, 57),
                  secondaryColor: const Color.fromARGB(255, 245, 230, 225),
                  onTap: () {
                    setState(() {
                      currentAccount.theme = "Clay";
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
      bottomNavigationBar: const NavigationFooter(),
    );
  }
}