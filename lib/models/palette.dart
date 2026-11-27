import 'package:material_ui/material_ui.dart';

class ColorPalette {
  final String name;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color smoke;
  final Color eggWhite;
  final Color thinGreen;
  final List<Color> announcementColors;

  const ColorPalette({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.smoke,
    required this.eggWhite,
    required this.thinGreen,
    required this.announcementColors,
  });
}

class AppPalettes {
  static const ColorPalette coastal = ColorPalette(
    name: 'Coastal',
    primary: Color.fromARGB(255, 16, 108, 103),
    secondary: Color.fromARGB(255, 230, 242, 238),
    background: Colors.white,
    textPrimary: Colors.black,
    textSecondary: Color.fromARGB(255, 120, 120, 120),
    smoke: Color.fromARGB(255, 224, 224, 224),
    eggWhite: Color.fromARGB(255, 224, 224, 224),
    thinGreen: Color.fromARGB(255, 230, 242, 238),
    announcementColors: [
      Color.fromARGB(255, 16, 108, 103),
      Color.fromARGB(255, 160, 78, 57),
      Color.fromARGB(255, 41, 128, 185),
    ],
  );

  static const ColorPalette dark = ColorPalette(
    name: 'Dark',
    primary: Color.fromARGB(255, 30, 144, 255),
    secondary: Color.fromARGB(255, 50, 50, 50),
    background: Color.fromARGB(255, 18, 18, 18),
    textPrimary: Colors.white,
    textSecondary: Color.fromARGB(255, 200, 200, 200),
    smoke: Color.fromARGB(255, 70, 70, 70),
    eggWhite: Color.fromARGB(255, 60, 60, 60),
    thinGreen: Color.fromARGB(255, 40, 70, 70),
    announcementColors: [
      Color.fromARGB(255, 30, 144, 255),
      Color.fromARGB(255, 220, 100, 80),
      Color.fromARGB(255, 70, 180, 120),
    ],
  );

  static const ColorPalette clay = ColorPalette(
    name: 'Clay',
    primary: Color.fromARGB(255, 160, 78, 57),
    secondary: Color.fromARGB(255, 245, 230, 225),
    background: Color.fromARGB(255, 253, 250, 248),
    textPrimary: Color.fromARGB(255, 40, 30, 25),
    textSecondary: Color.fromARGB(255, 130, 110, 100),
    smoke: Color.fromARGB(255, 230, 215, 205),
    eggWhite: Color.fromARGB(255, 230, 215, 205),
    thinGreen: Color.fromARGB(255, 245, 230, 225),
    announcementColors: [
      Color.fromARGB(255, 160, 78, 57),
      Color.fromARGB(255, 201, 126, 40),
      Color.fromARGB(255, 88, 129, 87),
    ],
  );

  static ColorPalette fromName(String name) {
    switch (name) {
      case 'Dark':
        return dark;
      case 'Clay':
        return clay;
      case 'Coastal':
      default:
        return coastal;
    }
  }
}
