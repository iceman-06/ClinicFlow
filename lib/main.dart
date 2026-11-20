import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/pages/client/home_page.dart' as client_home;
import 'package:clinicflow/pages/staff/home_page.dart' as staff_home;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClinicFlow',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: currentAccount.isStaff
          ? const staff_home.HomePage()
          : const client_home.HomePage(),
    );
  }
}