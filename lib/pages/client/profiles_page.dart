import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/pages/components.dart';
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
                        color: Colours.green,
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
                  color: Colours.thinGreen,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: BetterText(
                  text: profile.isAccountHolder ? "Account holder" : "Family member",
                  size: 11.0,
                  colour: Colours.green,
                  weight: 600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          BetterText(
            text: "${profile.formattedDob} · ${profile.phone}",
            size: 12.0,
            colour: const Color.fromARGB(255, 100, 100, 100),
          ),
          const SizedBox(height: 8.0),
          BetterText(text: profile.upcomingBooking, size: 14.0, weight: 500),
          if (profile.bookingSubInfo.isNotEmpty) ...[
            const SizedBox(height: 2.0),
            BetterText(
              text: profile.bookingSubInfo,
              size: 12.0,
              colour: const Color.fromARGB(255, 100, 100, 100),
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
                  colour: isActive ? Colours.green : Colors.black,
                ),
              ),
              GestureDetector(
                onTap: onManage,
                child: const BetterText(
                  text: "Manage",
                  weight: 600,
                  size: 13.0,
                  colour: Color.fromARGB(255, 80, 80, 80),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          const Divider(thickness: 1.0, color: Colours.eggWhite),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BetterText(text: 'Family profiles', size: 30.0),
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
            const BetterText(
              text: "Manage the people registered to this account.",
              size: 14.0,
              colour: Color.fromARGB(255, 100, 100, 100),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colours.lightSmoke, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                color: Colours.thinGreen,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BetterText(
                    text: "${currentAccount.profiles.length} family members",
                    weight: 600,
                    size: 16.0,
                  ),
                  const SizedBox(height: 4.0),
                  const BetterText(
                    text: "Jamie is the account holder. Add a new member below.",
                    size: 12.0,
                    colour: Color.fromARGB(255, 80, 80, 80),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BetterText(
                  text: "Registered family members",
                  size: 18.0,
                  weight: 600,
                ),
                BetterText(
                  text: "${currentAccount.profiles.length} members",
                  size: 12.0,
                  colour: const Color.fromARGB(255, 100, 100, 100),
                ),
              ],
            ),
            const Divider(thickness: 1.0, color: Colours.eggWhite, height: 16.0),
            for (var profile in currentAccount.profiles)
              FamilyMemberCard(
                profile: profile,
                isActive: profile.id == currentAccount.activeProfileId,
                onSelectProfile: () {
                  setState(() {
                    currentAccount.activeProfileId = profile.id;
                  });
                },
                onManage: () {},
              ),
            const SizedBox(height: 12.0),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _addNewMember,
                style: FilledButton.styleFrom(
                  backgroundColor: Colours.green,
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