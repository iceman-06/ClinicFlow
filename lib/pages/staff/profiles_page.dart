import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/pages/components.dart';
import 'package:clinicflow/models/account.dart';

class StaffProfileCard extends StatelessWidget {
  final String name;
  final String clientId;
  final String dobAndPhone;
  final String bookingInfo;
  final String bookingSubInfo;
  final VoidCallback onViewProfile;
  final VoidCallback onBookForClient;

  const StaffProfileCard({
    super.key,
    required this.name,
    required this.clientId,
    required this.dobAndPhone,
    required this.bookingInfo,
    required this.bookingSubInfo,
    required this.onViewProfile,
    required this.onBookForClient,
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
              BetterText(text: name, weight: 600, size: 16.0),
              BetterText(
                text: clientId,
                size: 13.0,
                colour: const Color.fromARGB(255, 120, 120, 120),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          BetterText(
            text: dobAndPhone,
            size: 12.0,
            colour: const Color.fromARGB(255, 120, 120, 120),
          ),
          const SizedBox(height: 8.0),
          BetterText(text: bookingInfo, size: 14.0, weight: 500),
          const SizedBox(height: 2.0),
          BetterText(
            text: bookingSubInfo,
            size: 12.0,
            colour: const Color.fromARGB(255, 120, 120, 120),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onViewProfile,
                child: const BetterText(
                  text: "View profile",
                  weight: 600,
                  size: 13.0,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onBookForClient,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                  side: const BorderSide(color: Colours.lightSmoke, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16.0, color: Colors.black),
                label: const BetterText(
                  text: "Book for client",
                  weight: 600,
                  size: 13.0,
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
  final TextEditingController _searchController = TextEditingController(text: "Chen");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BetterText(text: 'Profiles', size: 30.0),
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
              text: "Find a client to view or book an appointment.",
              size: 14.0,
              colour: Color.fromARGB(255, 100, 100, 100),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 120, 120, 120)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Color.fromARGB(255, 120, 120, 120)),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                hintText: "Search...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colours.lightSmoke, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colours.lightSmoke, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 4.0),
            const BetterText(
              text: "Search by name, client ID or phone number",
              size: 11.0,
              colour: Color.fromARGB(255, 120, 120, 120),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BetterText(
                  text: "Search results",
                  size: 18.0,
                  weight: 600,
                ),
                const BetterText(
                  text: "3 clients",
                  size: 12.0,
                  colour: Color.fromARGB(255, 120, 120, 120),
                ),
              ],
            ),
            const Divider(thickness: 1.0, color: Colours.eggWhite, height: 16.0),
            StaffProfileCard(
              name: "Jamie Chen",
              clientId: "CL-1042",
              dobAndPhone: "DOB 12 Mar 1992 · 07700 900142",
              bookingInfo: "Today, 9 Nov · 14:30–15:00",
              bookingSubInfo: "Follow-up · Checked in",
              onViewProfile: () {},
              onBookForClient: () {},
            ),
            StaffProfileCard(
              name: "Olivia Chen",
              clientId: "CL-1186",
              dobAndPhone: "DOB 24 Aug 1985 · 07700 900186",
              bookingInfo: "No upcoming booking",
              bookingSubInfo: "Last visit: Today at 12:00 · Done",
              onViewProfile: () {},
              onBookForClient: () {},
            ),
            StaffProfileCard(
              name: "Daniel Chen",
              clientId: "CL-1253",
              dobAndPhone: "DOB 06 Feb 1978 · 07700 900253",
              bookingInfo: "Tue, 10 Nov · 10:00–10:45",
              bookingSubInfo: "Initial consultation · Confirmed",
              onViewProfile: () {},
              onBookForClient: () {},
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
      bottomNavigationBar: const NavigationFooter(),
    );
  }
}