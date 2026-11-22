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

  void _submit() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    loadDefaultAccount();
    currentAccount.primaryEmail = _emailController.text.trim();
    if (!_isLogin && _nameController.text.isNotEmpty) {
      currentAccount.name = _nameController.text.trim();
      currentAccount.profiles.first.name = _nameController.text.trim();
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

  @override
  Widget build(BuildContext context) {
    loadDefaultAccount(); // Fallback palette access for auth screen
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
                child: OutlinedButton(
                  onPressed: _loginAsDefault,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: palette.primary),
                  ),
                  child: Text(
                    currentAccount.t('default_account'),
                    style: TextStyle(color: palette.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login",
                  style: TextStyle(color: palette.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}