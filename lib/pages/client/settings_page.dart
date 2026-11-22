import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
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

  void _manageContactDetails() {
    final emailController = TextEditingController(text: currentAccount.email);
    final phoneController = TextEditingController(text: currentAccount.phone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: "Manage Contact Details", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: BetterText(text: "Cancel", colour: currentAccount.palette.primary),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                currentAccount.email = emailController.text;
                currentAccount.phone = phoneController.text;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Contact details updated successfully")),
              );
            },
            child: BetterText(text: "Save", colour: currentAccount.palette.primary, weight: 600),
          ),
        ],
      ),
    );
  }

  void _reviewPrivacy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: "Privacy Policy", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: BetterText(
          text: "Your data is securely encrypted and handled in accordance with Canadian healthcare privacy standards (PIPEDA).",
          size: 14.0,
          colour: currentAccount.palette.textPrimary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: BetterText(text: "Close", colour: currentAccount.palette.primary, weight: 600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentAccount.palette.background,
      appBar: AppBar(
        backgroundColor: currentAccount.palette.background,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BetterText(text: 'Settings', size: 30.0, colour: currentAccount.palette.textPrimary),
            const ProfileIconButton(),
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
              colour: currentAccount.palette.textSecondary,
            ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _switchRole,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  side: BorderSide(color: currentAccount.palette.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: Icon(Icons.swap_horiz, color: currentAccount.palette.primary),
                label: BetterText(
                  text: "Switch to Staff View",
                  colour: currentAccount.palette.primary,
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
              onTap: _manageContactDetails,
            ),
            SettingsTile(
              title: "Privacy",
              trailingText: currentAccount.privacyStatusText,
              onTap: _reviewPrivacy,
            ),
            const SizedBox(height: 20.0),
            const SettingsSectionHeader(
              title: "Colour theme",
              subtitle: "A little colour for your everyday care.",
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
                  primaryColor: const Color.fromARGB(255, 30, 144, 255),
                  secondaryColor: const Color.fromARGB(255, 50, 50, 50),
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