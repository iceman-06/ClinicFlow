import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/models/clinic.dart';
import 'package:clinicflow/pages/client/clinic_search_page.dart';
import 'package:clinicflow/services/firestore_service.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:material_ui/material_ui.dart';

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
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: currentAccount.palette.smoke.withAlpha(100),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: BetterText(
                      text: profile.isAdult ? currentAccount.t('adult') : currentAccount.t('child'),
                      size: 11.0, colour: currentAccount.palette.textPrimary, weight: 600,
                    ),
                  ),
                  if (!profile.isAccountHolder && onDelete != null) ...[
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: currentAccount.t('remove_profile_tooltip'),
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
  Future<void> _addNewMember(List<UserProfile> currentProfiles) async {
    final newId = 'CL-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final newProfile = UserProfile(
      id: newId,
      accountId: currentAccount.id,
      name: currentAccount.t('new_member'),
      clientId: newId,
      dob: DateTime(2000, 1, 1),
      phone: '613-555-0100',
      primaryPhone: currentAccount.primaryPhone,
      isAccountHolder: false,
      upcomingBooking: currentAccount.t('no_upcoming_booking'),
      bookingSubInfo: currentAccount.t('newly_added_profile'),
    );
    await FirestoreService.saveProfile(currentAccount.id, newProfile);
  }

  void _removeProfile(UserProfile profile, List<UserProfile> currentProfiles) {
    if (profile.isAccountHolder) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: currentAccount.palette.background,
        title: BetterText(text: currentAccount.t('remove_profile'), weight: 600, size: 18.0, colour: currentAccount.palette.textPrimary),
        content: BetterText(text: currentAccount.t('confirm_remove', replacements: [profile.name]), size: 14.0, colour: currentAccount.palette.textPrimary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: BetterText(text: currentAccount.t('cancel'), colour: currentAccount.palette.primary),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirestoreService.deleteProfile(currentAccount.id, profile.id);
              if (currentAccount.activeProfileId == profile.id && currentProfiles.isNotEmpty) {
                final fallback = currentProfiles.firstWhere(
                  (p) => p.id != profile.id,
                  orElse: () => currentProfiles.first,
                );
                currentAccount.activeProfileId = fallback.id;
                await FirestoreService.saveAccount(currentAccount);
              }
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(currentAccount.t('profile_removed'))),
              );
            },
            child: BetterText(text: currentAccount.t('remove'), colour: Colors.red, weight: 600),
          ),
        ],
      ),
    );
  }

  void _manageProfile(UserProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageProfilePage(profile: profile),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
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
        title: BetterText(text: currentAccount.t('family_profiles'), size: 24.0, colour: currentAccount.palette.textPrimary),
        actions: const [Padding(padding: EdgeInsets.only(right: 12.0), child: ProfileIconButton())],
      ),
      body: StreamBuilder<List<UserProfile>>(
        stream: FirestoreService.streamProfiles(currentAccount.id),
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
                          text: "${profiles.length} ${currentAccount.t('family_members')}",
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
                        text: "${profiles.length} ${currentAccount.t('members')}",
                        size: 12.0,
                        colour: currentAccount.palette.textSecondary,
                      ),
                    ],
                  ),
                  Divider(thickness: 1.0, color: currentAccount.palette.smoke, height: 16.0),
                  for (var profile in profiles)
                    FamilyMemberCard(
                      profile: profile,
                      isActive: profile.id == currentAccount.activeProfileId,
                      onSelectProfile: () async {
                        setState(() {
                          currentAccount.activeProfileId = profile.id;
                        });
                        await FirestoreService.saveAccount(currentAccount);
                      },
                      onManage: () => _manageProfile(profile),
                      onDelete: profile.isAccountHolder ? null : () => _removeProfile(profile, profiles),
                    ),
                  const SizedBox(height: 12.0),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _addNewMember(profiles),
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
          );
        },
      ),
      bottomNavigationBar: const NavigationFooter(currentPage: 'profiles'),
    );
  }
}

class ManageProfilePage extends StatefulWidget {
  final UserProfile profile;

  const ManageProfilePage({super.key, required this.profile});

  @override
  State<ManageProfilePage> createState() => _ManageProfilePageState();
}

class _ManageProfilePageState extends State<ManageProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;

  UserProfile get _targetProfile {
    return currentAccount.profiles.firstWhere(
      (p) => p.id == widget.profile.id,
      orElse: () => widget.profile,
    );
  }

  @override
  void initState() {
    super.initState();
    final target = _targetProfile;
    _nameController = TextEditingController(text: target.name);
    _phoneController = TextEditingController(text: target.phone);
    _dobController = TextEditingController(
      text:
          "${target.dob.year}-${target.dob.month.toString().padLeft(2, '0')}-${target.dob.day.toString().padLeft(2, '0')}",
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final nameParts = _nameController.text.trim().split(RegExp(r'\s+'));
    if (nameParts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentAccount.t('error_name_two_words'))),
      );
      return;
    }

    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentAccount.t('error_phone_ten'))),
      );
      return;
    }

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(_dobController.text);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentAccount.t('error_dob_format'))),
      );
      return;
    }

    final target = _targetProfile;
    target.name = _nameController.text.trim();
    target.phone =
        '${cleanPhone.substring(0, 3)}-${cleanPhone.substring(3, 6)}-${cleanPhone.substring(6)}';
    target.dob = parsedDate;

    await FirestoreService.saveProfile(currentAccount.id, target);
    if (target.isAccountHolder) {
      currentAccount.name = target.name;
      await FirestoreService.saveAccount(currentAccount);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(currentAccount.t('profile_updated'))),
    );
    Navigator.pop(context);
  }

  Future<void> _removeClinic(String clinicId) async {
    final target = _targetProfile;
    setState(() {
      target.clinicIds.remove(clinicId);
    });
    await FirestoreService.saveProfile(currentAccount.id, target);
  }

  @override
  Widget build(BuildContext context) {
    final palette = currentAccount.palette;
    final target = _targetProfile;
    final associatedClinics = sampleClinics
        .where((c) => target.clinicIds.contains(c.id))
        .toList();

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: BetterText(
          text: "${currentAccount.t('manage')} ${target.name}",
          size: 20.0,
          weight: 600,
          colour: palette.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              style: TextStyle(color: palette.textPrimary),
              decoration: themedInputDecoration(labelText: currentAccount.t('full_name_min')),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _phoneController,
              style: TextStyle(color: palette.textPrimary),
              decoration: themedInputDecoration(labelText: currentAccount.t('secondary_phone')),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _dobController,
              style: TextStyle(color: palette.textPrimary),
              decoration: themedInputDecoration(labelText: currentAccount.t('dob_format')),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BetterText(
                  text: 'Associated clinics (${associatedClinics.length})',
                  size: 16.0,
                  weight: 600,
                  colour: palette.textPrimary,
                ),
                TextButton.icon(
                  onPressed: () {
                    currentAccount.activeProfileId = target.id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddClinicPage()),
                    ).then((_) {
                      if (mounted) setState(() {});
                    });
                  },
                  icon: Icon(Icons.add, size: 18, color: palette.primary),
                  label: BetterText(
                    text: 'Add clinic',
                    size: 13.0,
                    weight: 600,
                    colour: palette.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (associatedClinics.isEmpty)
              BetterText(
                text: 'No clinics associated with ${target.name} yet.',
                size: 13.0,
                colour: palette.textSecondary,
              )
            else
              for (final clinic in associatedClinics)
                Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: palette.smoke),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: BetterText(
                      text: clinic.name,
                      size: 15.0,
                      weight: 600,
                      colour: palette.textPrimary,
                    ),
                    subtitle: BetterText(
                      text: '${clinic.specialty} · ${clinic.address}',
                      size: 12.0,
                      colour: palette.textSecondary,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => _removeClinic(clinic.id),
                    ),
                  ),
                ),
            const SizedBox(height: 24.0),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: _saveProfile,
                style: FilledButton.styleFrom(backgroundColor: palette.primary),
                child: BetterText(
                  text: currentAccount.t('save'),
                  size: 15.0,
                  weight: 600,
                  colour: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}