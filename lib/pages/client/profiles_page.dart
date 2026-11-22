import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';

class FamilyMemberCard extends StatelessWidget {
  final UserProfile profile;
  final bool isActive;
  final VoidCallback onSelectProfile;
  final VoidCallback onManage;
  final VoidCallback? onDelete;

  const FamilyMemberCard({
    super.key,
    required this.profile,
    required this.isActive,
    required this.onSelectProfile,
    required this.onManage,
    this.onDelete,
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
              Row(
                children: [
                  BetterText(text: profile.name, weight: 600, size: 16.0),
                  if (isActive) ...[
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: currentAccount.palette.primary,
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: BetterText(
                        text: currentAccount.t('active'),
                        size: 10.0,
                        colour: Colors.white,
                        weight: 600,
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: currentAccount.palette.secondary,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: BetterText(
                      text: profile.isAccountHolder ? currentAccount.t('account_holder') : currentAccount.t('family_member'),
                      size: 11.0,
                      colour: currentAccount.palette.primary,
                      weight: 600,
                    ),
                  ),
                  if (!profile.isAccountHolder && onDelete != null) ...[
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: "Remove profile",
                    ),
                  ],
                ],
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
          BetterText(text: profile.upcomingBooking == 'No upcoming booking' ? currentAccount.t('no_upcoming_booking') : profile.upcomingBooking, size: 14.0, weight: 500),
          if (profile.bookingSubInfo.isNotEmpty) ...[
            const SizedBox(height: 2.0),
            BetterText(
              text: profile.bookingSubInfo,
              size: 12.0,
              colour: currentAccount.palette.textSecondary,
            ),
          ],
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onSelectProfile,
                child: BetterText(
                  text: isActive ? currentAccount.t('viewing_profile') : currentAccount.t('switch_to_profile'),
                  weight: 600,
                  size: 13.0,
                  colour: isActive ? currentAccount.palette.primary : currentAccount.palette.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: onManage,
                child: BetterText(
                  text: currentAccount.t('manage'),
                  weight: 600,
                  size: 13.0,
                  colour: currentAccount.palette.textSecondary,
                ),
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
  void _addNewMember() {
    setState(() {
      final newId = 'CL-${1000 + currentAccount.profiles.length + 1}';
      currentAccount.profiles.add(
        UserProfile(
          id: newId,
          name: 'New Member',
          clientId: newId,
          dob: DateTime(2000, 1, 1),
          phone: '613-555-0100',
          primaryPhone: currentAccount.primaryPhone,
          isAccountHolder: false,
          upcomingBooking: currentAccount.t('no_upcoming_booking'),
          bookingSubInfo: 'Newly added profile',
        ),
      );
    });
  }

  void _removeProfile(UserProfile profile) {
    if (profile.isAccountHolder) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: "Remove Profile", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: BetterText(text: "Are you sure you want to remove ${profile.name}?", size: 14.0, colour: currentAccount.palette.textPrimary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: BetterText(text: currentAccount.t('cancel'), colour: currentAccount.palette.primary),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                currentAccount.profiles.removeWhere((p) => p.id == profile.id);
                if (currentAccount.activeProfileId == profile.id) {
                  currentAccount.activeProfileId = currentAccount.profiles.first.id;
                }
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile removed successfully")),
              );
            },
            child: const BetterText(text: "Remove", colour: Colors.red, weight: 600),
          ),
        ],
      ),
    );
  }

  void _manageProfile(UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final phoneController = TextEditingController(text: profile.phone);
    final dobController = TextEditingController(text: "${profile.dob.year}-${profile.dob.month.toString().padLeft(2, '0')}-${profile.dob.day.toString().padLeft(2, '0')}");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: "${currentAccount.t('manage')} ${profile.name}", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name (Two words min)"),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Secondary Phone (10 digits)"),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(labelText: "Date of Birth (YYYY-MM-DD)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: BetterText(text: currentAccount.t('cancel'), colour: currentAccount.palette.primary),
          ),
          TextButton(
            onPressed: () {
              final nameParts = nameController.text.trim().split(RegExp(r'\s+'));
              if (nameParts.length < 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error: Name must be at least two words.")),
                );
                return;
              }

              final cleanPhone = phoneController.text.replaceAll(RegExp(r'\D'), '');
              if (cleanPhone.length != 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error: Phone number must be exactly 10 digits.")),
                );
                return;
              }

              DateTime? parsedDate;
              try {
                parsedDate = DateTime.parse(dobController.text);
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error: Date of Birth must be in YYYY-MM-DD format.")),
                );
                return;
              }

              setState(() {
                profile.name = nameController.text.trim();
                profile.phone = "${cleanPhone.substring(0,3)}-${cleanPhone.substring(3,6)}-${cleanPhone.substring(6)}";
                profile.dob = parsedDate!;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile updated successfully")),
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
    setState(() {});
    return Scaffold(
      backgroundColor: currentAccount.palette.background,
      appBar: AppBar(
        backgroundColor: currentAccount.palette.background,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BetterText(text: currentAccount.t('family_profiles'), size: 30.0, colour: currentAccount.palette.textPrimary),
            const ProfileIconButton(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BetterText(
              text: currentAccount.t('manage_family_desc'),
              size: 14.0,
              colour: currentAccount.palette.textSecondary,
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: currentAccount.palette.smoke, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                color: currentAccount.palette.secondary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BetterText(
                    text: "${currentAccount.profiles.length} ${currentAccount.t('family_members')}",
                    weight: 600,
                    size: 16.0,
                    colour: currentAccount.palette.textPrimary,
                  ),
                  const SizedBox(height: 4.0),
                  BetterText(
                    text: currentAccount.t('add_new_family_member_below'),
                    size: 12.0,
                    colour: currentAccount.palette.textSecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BetterText(
                  text: currentAccount.t('registered_family_members'),
                  size: 18.0,
                  weight: 600,
                  colour: currentAccount.palette.textPrimary,
                ),
                BetterText(
                  text: "${currentAccount.profiles.length} members",
                  size: 12.0,
                  colour: currentAccount.palette.textSecondary,
                ),
              ],
            ),
            Divider(thickness: 1.0, color: currentAccount.palette.smoke, height: 16.0),
            for (var profile in currentAccount.profiles)
              FamilyMemberCard(
                profile: profile,
                isActive: profile.id == currentAccount.activeProfileId,
                onSelectProfile: () {
                  setState(() {
                    currentAccount.activeProfileId = profile.id;
                  });
                },
                onManage: () => _manageProfile(profile),
                onDelete: profile.isAccountHolder ? null : () => _removeProfile(profile),
              ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _addNewMember,
                style: FilledButton.styleFrom(
                  backgroundColor: currentAccount.palette.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: BetterText(
                  text: currentAccount.t('add_new_member'),
                  colour: Colors.white,
                  weight: 600,
                  size: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
      bottomNavigationBar: const NavigationFooter(currentPage: 'profiles'),
    );
  }
}