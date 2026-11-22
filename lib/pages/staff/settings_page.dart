import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/models/translation.dart';
import 'package:clinicflow/pages/client/settings_page.dart' as client_settings;

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
            ? const SettingsPage()
            : const client_settings.SettingsPage(),
      ),
    );
  }

  void _switchLanguage() {
    setState(() {
      currentAccount.toggleLanguage();
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Scaffold(
      backgroundColor: currentAccount.palette.background,
      appBar: AppBar(
        backgroundColor: currentAccount.palette.background,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BetterText(text: currentAccount.t('settings'), size: 30.0, colour: currentAccount.palette.textPrimary),
            const ProfileIconButton(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSectionHeader(title: currentAccount.t('staff_account')),
            const SizedBox(height: 4.0),
            BetterText(
              text: "${currentAccount.name} · ${currentAccount.t('clinic_staff_member')}",
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
                  text: currentAccount.t('switch_to_patient'),
                  colour: currentAccount.palette.primary,
                  weight: 600,
                  size: 14.0,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            SettingsSectionHeader(
              title: currentAccount.t('staff_preferences'),
            ),
            const SizedBox(height: 8.0),
            SettingsTile(
              title: currentAccount.t('staff_notifications'),
              trailingText: currentAccount.staffNotifications ? "On" : "Off",
              onTap: () {
                setState(() {
                  currentAccount.staffNotifications = !currentAccount.staffNotifications;
                });
              },
            ),
            SettingsTile(
              title: currentAccount.t('automated_check_in_prompts'),
              trailingText: currentAccount.automatedCheckInPrompts ? "Enabled" : "Disabled",
              onTap: () {
                setState(() {
                  currentAccount.automatedCheckInPrompts = !currentAccount.automatedCheckInPrompts;
                });
              },
            ),
            const SizedBox(height: 16.0),
            SettingsSectionHeader(title: currentAccount.t('language')),
            const SizedBox(height: 8.0),
            SettingsTile(
              title: currentAccount.t('language'),
              trailingText: currentAccount.language == AppLanguage.english ? 'English' : 'Français',
              onTap: _switchLanguage,
            ),
            const SizedBox(height: 16.0),
            SettingsSectionHeader(
              title: currentAccount.t('colour_theme'),
              subtitle: "A little colour for your everyday care.",
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ThemeCard(
                  title: currentAccount.t('theme_coastal'),
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
                  title: currentAccount.t('theme_dark'),
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
                  title: currentAccount.t('theme_clay'),
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
      bottomNavigationBar: const NavigationFooter(currentPage: 'settings'),
    );
  }
}