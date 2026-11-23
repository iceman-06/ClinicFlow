import 'package:material_ui/material_ui.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/models/translation.dart';
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

  @override
  void initState() {
    super.initState();
    loadDefaultAccount();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(currentAccount.t('error_valid_email'))),
      );
      return;
    }

    if (!_isLogin) {
      if (name.split(RegExp(r'\s+')).length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(currentAccount.t('error_name_two_words'))),
        );
        return;
      }
      if (password.length < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(currentAccount.t('error_password_length'))),
        );
        return;
      }
    } else {
      if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(currentAccount.t('error_password_required'))),
        );
        return;
      }
    }

    final selectedLanguage = currentAccount.language;
    loadDefaultAccount();
    currentAccount.language = selectedLanguage;
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
    final selectedLanguage = currentAccount.language;
    loadDefaultAccount();
    currentAccount.language = selectedLanguage;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const client_home.HomePage()),
    );
  }

  void _loginWithGoogle() {
    final selectedLanguage = currentAccount.language;
    loadDefaultAccount();
    currentAccount.language = selectedLanguage;
    currentAccount.primaryEmail = "jamie.chen@gmail.com";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const client_home.HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => currentAccount.toggleLanguage()),
                  icon: const Icon(Icons.language),
                  label: Text(currentAccount.language == AppLanguage.english ? 'English' : 'Français'),
                ),
              ),
              const SizedBox(height: 20),
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
                  _isLogin ? currentAccount.t('signup_prompt') : currentAccount.t('login_prompt'),
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