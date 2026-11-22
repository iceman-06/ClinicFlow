import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';

class FamilyMemberCard extends StatelessWidget {
  final UserProfile profile;
  final bool isActive;
  final VoidCallback onSelectProfile;
  final VoidCallback onManage;

  const FamilyMemberCard({
    super.key,
    required this.profile,
    required this.isActive,
    required this.onSelectProfile,
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
                      child: const BetterText(
                        text: "Active",
                        size: 10.0,
                        colour: Colors.white,
                        weight: 600,
                      ),
                    ),
                  ],
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: currentAccount.palette.secondary,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: BetterText(
                  text: profile.isAccountHolder ? "Account holder" : "Family member",
                  size: 11.0,
                  colour: currentAccount.palette.primary,
                  weight: 600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          BetterText(
            text: "${profile.formattedDob} · ${profile.phone}",
            size: 12.0,
            colour: currentAccount.palette.textSecondary,
          ),
          const SizedBox(height: 8.0),
          BetterText(text: profile.upcomingBooking, size: 14.0, weight: 500),
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
                  text: isActive ? "Viewing profile" : "Switch to profile",
                  weight: 600,
                  size: 13.0,
                  colour: isActive ? currentAccount.palette.primary : currentAccount.palette.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: onManage,
                child: BetterText(
                  text: "Manage",
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
          name: 'New Family Member',
          clientId: newId,
          dob: DateTime(2000, 1, 1),
          phone: '07700 900000',
          isAccountHolder: false,
          upcomingBooking: 'No upcoming booking',
          bookingSubInfo: 'Newly added profile',
        ),
      );
    });
  }

  void _manageProfile(UserProfile profile) {
    final nameController = TextEditingController(text: profile.name);
    final phoneController = TextEditingController(text: profile.phone);
    final dobController = TextEditingController(text: "${profile.dob.year}-${profile.dob.month.toString().padLeft(2, '0')}-${profile.dob.day.toString().padLeft(2, '0')}");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: "Manage ${profile.name}", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
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
            child: BetterText(text: "Cancel", colour: currentAccount.palette.primary),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                profile.name = nameController.text;
                profile.phone = phoneController.text;
                try {
                  final parsedDate = DateTime.parse(dobController.text);
                  profile.dob = parsedDate;
                } catch (_) {}
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile updated successfully")),
              );
            },
            child: BetterText(text: "Save", colour: currentAccount.palette.primary, weight: 600),
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
            BetterText(text: 'Family profiles', size: 30.0, colour: currentAccount.palette.textPrimary),
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
              text: "Manage the people registered to this account.",
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
                    text: "${currentAccount.profiles.length} family members",
                    weight: 600,
                    size: 16.0,
                    colour: currentAccount.palette.textPrimary,
                  ),
                  const SizedBox(height: 4.0),
                  BetterText(
                    text: "Jamie is the account holder. Add a new member below.",
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
                  text: "Registered family members",
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
                label: const BetterText(
                  text: "Add new member",
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
      bottomNavigationBar: const NavigationFooter(),
    );
  }
}