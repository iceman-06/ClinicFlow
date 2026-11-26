import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/services/firestore_service.dart';
import 'package:clinicflow/pages/staff/calendar_page.dart' as staff_calendar;

class StaffProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onViewProfile;
  final VoidCallback onBookForClient;
  final VoidCallback onManage;

  const StaffProfileCard({
    super.key,
    required this.profile,
    required this.onViewProfile,
    required this.onBookForClient,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BetterText(text: profile.name, weight: 600, size: 16.0, colour: currentAccount.palette.textPrimary),
              BetterText(
                text: profile.clientId,
                size: 13.0,
                colour: currentAccount.palette.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          BetterText(
            text: "${profile.formattedDob} · ${currentAccount.t('secondary')}: ${profile.phone}",
            size: 12.0,
            colour: currentAccount.palette.textSecondary,
          ),
          const SizedBox(height: 8.0),
          BetterText(
            text: profile.upcomingBooking == 'No upcoming booking'
                ? currentAccount.t('no_upcoming_booking')
                : profile.upcomingBooking,
            size: 14.0,
            weight: 500,
            colour: currentAccount.palette.textPrimary,
          ),
          const SizedBox(height: 2.0),
          BetterText(
            text: profile.bookingSubInfo,
            size: 12.0,
            colour: currentAccount.palette.textSecondary,
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onViewProfile,
                child: BetterText(
                  text: currentAccount.t('view_profile'),
                  weight: 600,
                  size: 13.0,
                  colour: currentAccount.palette.textPrimary,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: onManage,
                    child: BetterText(
                      text: currentAccount.t('manage'),
                      weight: 600,
                      size: 13.0,
                      colour: currentAccount.palette.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  OutlinedButton.icon(
                    onPressed: onBookForClient,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                      side: BorderSide(color: currentAccount.palette.smoke, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    icon: Icon(Icons.add, size: 16.0, color: currentAccount.palette.textPrimary),
                    label: BetterText(
                      text: currentAccount.t('book_for_client'),
                      weight: 600,
                      size: 13.0,
                      colour: currentAccount.palette.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Divider(thickness: 1.0, color: currentAccount.palette.smoke),
        ],
      ),
    );
  }
}

class ProfilesPage extends StatefulWidget {
  const ProfilesPage({super.key});

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  void _manageClient(UserProfile profile) {
    final notesController = TextEditingController(text: profile.notes);
    final medReminderController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: "${currentAccount.t('manage')} ${profile.name}", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BetterText(text: currentAccount.t('primary_contact'), weight: 600, size: 14.0, colour: currentAccount.palette.primary),
              const SizedBox(height: 4.0),
              BetterText(text: currentAccount.t('phone_label', replacements: [profile.primaryPhone]), size: 13.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 12.0),
              BetterText(text: currentAccount.t('secondary_contact'), weight: 600, size: 14.0, colour: currentAccount.palette.primary),
              const SizedBox(height: 4.0),
              BetterText(text: currentAccount.t('phone_label', replacements: [profile.phone]), size: 13.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 16.0),
              BetterText(text: currentAccount.t('notes'), weight: 600, size: 14.0, colour: currentAccount.palette.textPrimary),
              const SizedBox(height: 6.0),
              TextField(
                controller: notesController,
                maxLines: 4,
                style: TextStyle(color: currentAccount.palette.textPrimary),
                decoration: themedInputDecoration(
                  hintText: currentAccount.t('patient_notes_placeholder'),
                ),
              ),
              const SizedBox(height: 16.0),
              BetterText(text: currentAccount.t('add_medication_reminder'), weight: 600, size: 14.0, colour: currentAccount.palette.primary),
              const SizedBox(height: 6.0),
              TextField(
                controller: medReminderController,
                maxLines: 2,
                style: TextStyle(color: currentAccount.palette.textPrimary),
                decoration: themedInputDecoration(
                  hintText: currentAccount.t('medication_reminder_hint'),
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
              profile.notes = notesController.text.trim();
              final medInstructions = medReminderController.text.trim();
              final ownerAccountId = profile.accountId.isNotEmpty ? profile.accountId : currentAccount.id;
              Navigator.pop(ctx);
              await FirestoreService.saveProfile(ownerAccountId, profile);
              if (medInstructions.isNotEmpty) {
                await FirestoreService.sendMedicationReminder(
                  accountId: ownerAccountId,
                  patientName: profile.name,
                  instructions: medInstructions,
                );
              }
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    medInstructions.isNotEmpty
                        ? currentAccount.t('medication_reminder_sent')
                        : currentAccount.t('client_notes_updated'),
                  ),
                ),
              );
            },
            child: BetterText(text: currentAccount.t('save'), colour: currentAccount.palette.primary, weight: 600),
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
        centerTitle: true,
        leadingWidth: 56,
        leading: const HelpMenuButton(),
        title: BetterText(text: currentAccount.t('profiles'), size: 24.0, colour: currentAccount.palette.textPrimary),
        actions: const [Padding(padding: EdgeInsets.only(right: 12.0), child: ProfileIconButton())],
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: FirestoreService.streamAllProfilesForStaff(),
        builder: (context, snapshot) {
          final profiles = snapshot.data ?? currentAccount.profiles;

          return GestureDetector(
            onHorizontalDragEnd: (details) => navigateBySwipe(context, 'profiles', details),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BetterText(
                    text: currentAccount.t('search_clients_desc'),
                    size: 14.0,
                    colour: currentAccount.palette.textSecondary,
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BetterText(
                        text: "${profiles.length} ${currentAccount.t('clients')}",
                        size: 12.0,
                        colour: currentAccount.palette.textSecondary,
                      ),
                    ],
                  ),
                  Divider(thickness: 1.0, color: currentAccount.palette.smoke, height: 16.0),
                  for (var profile in profiles)
                    StaffProfileCard(
                      profile: profile,
                      onViewProfile: () => _manageClient(profile),
                      onBookForClient: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const staff_calendar.CalendarPage()),
                        );
                      },
                      onManage: () => _manageClient(profile),
                    ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const NavigationFooter(currentPage: 'profiles'),
    );
  }
}