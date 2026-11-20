import 'package:clinicflow/main.dart';
import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/pages/components.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BetterText(text: 'Settings', size: 30.0),
            CircleAvatar(backgroundColor: Colours.eggWhite, child: Text("JD")),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [BetterText(text: "WIP", size: 120.0, weight: 600)],
        ),
      ),
      bottomNavigationBar: NavigationFooter(),
    );
  }
}