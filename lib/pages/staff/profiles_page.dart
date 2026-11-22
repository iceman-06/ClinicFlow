import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/models/account.dart';

class StaffProfileCard extends StatelessWidget {
  final String name;
  final String clientId;
  final String dobAndPhone;
  final String bookingInfo;
  final String bookingSubInfo;
  final VoidCallback onViewProfile;
  final VoidCallback onBookForClient;
  final VoidCallback onManage;

  const StaffProfileCard({
    super.key,
    required this.name,
    required this.clientId,
    required this.dobAndPhone,
    required this.bookingInfo,
    required this.bookingSubInfo,
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
              BetterText(text: name, weight: 600, size: 16.0, colour: currentAccount.palette.textPrimary),
              BetterText(
                text: clientId,
                size: 13.0,
                colour: currentAccount.palette.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          BetterText(
            text: dobAndPhone,
            size: 12.0,
            colour: currentAccount.palette.textSecondary,
          ),
          const SizedBox(height: 8.0),
          BetterText(text: bookingInfo, size: 14.0, weight: 500, colour: currentAccount.palette.textPrimary),
          const SizedBox(height: 2.0),
          BetterText(
            text: bookingSubInfo,
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
                  text: "View profile",
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
                      text: "Manage",
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
                      text: "Book for client",
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
  final TextEditingController _searchController = TextEditingController(text: "Chen");

  void _manageClient(String clientName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: "Manage $clientName", weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: BetterText(text: "Update client status, medical notes, or contact info here.", size: 14.0, colour: currentAccount.palette.textPrimary),
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
            BetterText(text: 'Profiles', size: 30.0, colour: currentAccount.palette.textPrimary),
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
              text: "Find a client to view or book an appointment.",
              size: 14.0,
              colour: currentAccount.palette.textSecondary,
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: currentAccount.palette.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: currentAccount.palette.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                hintText: "Search...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: currentAccount.palette.smoke, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: currentAccount.palette.smoke, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
            ),
            const SizedBox(height: 4.0),
            BetterText(
              text: "Search by name, client ID or phone number",
              size: 11.0,
              colour: currentAccount.palette.textSecondary,
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BetterText(
                  text: "Search results",
                  size: 18.0,
                  weight: 600,
                  colour: currentAccount.palette.textPrimary,
                ),
                BetterText(
                  text: "3 clients",
                  size: 12.0,
                  colour: currentAccount.palette.textSecondary,
                ),
              ],
            ),
            Divider(thickness: 1.0, color: currentAccount.palette.smoke, height: 16.0),
            StaffProfileCard(
              name: "Jamie Chen",
              clientId: "CL-1042",
              dobAndPhone: "DOB 12 Mar 1992 · 07700 900142",
              bookingInfo: "Today, 9 Nov · 14:30–15:00",
              bookingSubInfo: "Follow-up · Checked in",
              onViewProfile: () {},
              onBookForClient: () {},
              onManage: () => _manageClient("Jamie Chen"),
            ),
            StaffProfileCard(
              name: "Olivia Chen",
              clientId: "CL-1186",
              dobAndPhone: "DOB 24 Aug 1985 · 07700 900186",
              bookingInfo: "No upcoming booking",
              bookingSubInfo: "Last visit: Today at 12:00 · Done",
              onViewProfile: () {},
              onBookForClient: () {},
              onManage: () => _manageClient("Olivia Chen"),
            ),
            StaffProfileCard(
              name: "Daniel Chen",
              clientId: "CL-1253",
              dobAndPhone: "DOB 06 Feb 1978 · 07700 900253",
              bookingInfo: "Tue, 10 Nov · 10:00–10:45",
              bookingSubInfo: "Initial consultation · Confirmed",
              onViewProfile: () {},
              onBookForClient: () {},
              onManage: () => _manageClient("Daniel Chen"),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
      bottomNavigationBar: const NavigationFooter(),
    );
  }
}