import 'package:clinicflow/pages/client/profile_page.dart';
import 'package:clinicflow/pages/client/settings_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/pages/client/home_page.dart';
import 'package:clinicflow/pages/client/calender_page.dart';

class NavigationFooter extends StatelessWidget {
  const NavigationFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
            icon: Icon(Icons.home, color: Colours.green),
            tooltip: "Home",
            iconSize: 40,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarPage()),
              );
            },
            icon: Icon(Icons.calendar_month, color: Colours.green),
            tooltip: "Calender",
            iconSize: 40,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilesPage()),
              );
            },
            icon: Icon(Icons.people, color: Colours.green),
            tooltip: "Profiles",
            iconSize: 40,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            icon: Icon(Icons.settings, color: Colours.green),
            tooltip: "Settings",
            iconSize: 40,
          ),
        ],
      ),
    );
  }
}

// Commonly used colours
abstract final class Colours {
  static const Color green = Color.fromARGB(255, 16, 108, 103);
  static const Color eggWhite = Color.fromARGB(255, 224, 224, 224);
  static const Color thinGreen = Color.fromARGB(255, 230, 242, 238);
  static const Color lightSmoke = Color.fromARGB(255, 224, 224, 224);
}

// Makes making Text easier
class BetterText extends StatelessWidget {
  final String text;
  final double? size;
  final int? weight;
  final Color? colour;
  final TextAlign? align;

  const BetterText({
    super.key,
    required this.text,
    this.size,
    this.weight,
    this.colour,
    this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: colour ?? Colors.black,
        fontSize: size ?? 14.0,
        fontWeight: FontWeight(weight ?? 400),
      ),
      textAlign: align ?? TextAlign.start,
    );
  }
}
