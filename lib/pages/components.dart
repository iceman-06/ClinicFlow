import 'package:material_ui/material_ui.dart';

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
            onPressed: () {},
            icon: Icon(Icons.home, color: Colours.green),
            tooltip: "Home",
            iconSize: 40,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.calendar_month, color: Colours.green),
            tooltip: "Calender",
            iconSize: 40,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.people, color: Colours.green),
            tooltip: "Profiles",
            iconSize: 40,
          ),
          IconButton(
            onPressed: () {},
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
}

// Makes making Text easier
// Probably should turn this into stateless
class BetterText extends StatefulWidget {
  final String text;
  final double? size;
  final int? weight;
  final Color? colour;

  const BetterText({
    super.key,
    required this.text,
    this.size,
    this.weight,
    this.colour,
  });

  @override
  State<StatefulWidget> createState() => _BetterTextState();
}

class _BetterTextState extends State<BetterText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: TextStyle(
        color: widget.colour ?? Colors.black,
        fontSize: widget.size ?? 14.0,
        fontWeight: FontWeight(widget.weight ?? 400),
      ),
    );
  }
}
