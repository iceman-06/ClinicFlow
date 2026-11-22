import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/pages/client/home_page.dart' as client_home;

void main() {
  runApp(const ClinicFlowApp());
}

class ClinicFlowApp extends StatelessWidget {
  const ClinicFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClinicFlow',
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Please enter a valid email address.")),
      );
      return;
    }

    if (!_isLogin) {
      if (name.split(RegExp(r'\s+')).length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Name must be at least two words.")),
        );
        return;
      }
      if (password.length < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Password must be at least 5 characters.")),
        );
        return;
      }
    } else {
      if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: Please enter your password.")),
        );
        return;
      }
    }

    loadDefaultAccount();
    currentAccount.primaryEmail = email;
    if (!_isLogin && name.isNotEmpty) {
      currentAccount.name = name;
      currentAccount.profiles.first.name = name;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const client_home.HomePage()),
    );
  }

  void _loginAsDefault() {
    loadDefaultAccount();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const client_home.HomePage()),
    );
  }

  void _loginWithGoogle() {
    loadDefaultAccount();
    currentAccount.primaryEmail = "jamie.chen@gmail.com";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const client_home.HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    loadDefaultAccount();
    final palette = currentAccount.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ClinicFlow',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: palette.primary,
                ),
              ),
              const SizedBox(height: 32),
              if (!_isLogin) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: currentAccount.t('name'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: currentAccount.t('email'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: currentAccount.t('password'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(backgroundColor: palette.primary),
                  child: Text(_isLogin ? currentAccount.t('login') : currentAccount.t('signup')),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: palette.primary),
                  ),
                  icon: Icon(Icons.g_mobiledata, size: 28, color: palette.primary),
                  label: Text(
                    currentAccount.t('login_with_google'),
                    style: TextStyle(color: palette.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _loginAsDefault,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: palette.textSecondary),
                  ),
                  child: Text(
                    currentAccount.t('default_account'),
                    style: TextStyle(color: palette.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: palette.primary, width: 1.5),
                  backgroundColor: palette.secondary.withAlpha(50),
                ),
                child: Text(
                  _isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login",
                  style: TextStyle(color: palette.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}