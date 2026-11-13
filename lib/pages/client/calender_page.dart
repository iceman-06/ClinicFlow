import 'package:material_ui/material_ui.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text("Calender"),
      ),
    );
  }
}