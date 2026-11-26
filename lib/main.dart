import 'dart:math';
import 'package:material_ui/material_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clinicflow/firebase_options.dart';
import 'package:clinicflow/models/account.dart';
import 'package:clinicflow/models/translation.dart';
import 'package:clinicflow/services/firestore_service.dart';
import 'package:clinicflow/widgets/common_widgets.dart';
import 'package:clinicflow/pages/client/home_page.dart' as client_home;
import 'package:clinicflow/pages/staff/home_page.dart' as staff_home;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  loadDefaultAccount();
  runApp(const ClinicFlowApp());
}

class ClinicFlowApp extends StatelessWidget {
  const ClinicFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ClinicFlow',
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Set to true to enable the Google Sign-In button (logs into the default demo account).
  static const bool enableGoogleSignIn = false;

  static const String _defaultDemoEmail = 'jamie.chen@clinicflow.app';
  static const String _defaultDemoPassword = 'ClinicFlowDemo2026!';

  static const List<String> _firstNames = [
    'Alex', 'Maya', 'Liam', 'Chloe', 'Noah', 'Sophie',
    'Ethan', 'Claire', 'Lucas', 'Emma', 'Owen', 'Hannah',
  ];
  static const List<String> _lastNames = [
    'Tremblay', 'Patel', 'Gagnon', 'Martin', 'Roy', 'Lee',
    'Bouchard', 'Wilson', 'Cote', 'Anderson', 'Nguyen', 'Clark',
  ];

  bool _isLogin = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDefaultAccount();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return currentAccount.t('error_invalid_credentials');
      case 'email-already-in-use':
        return currentAccount.t('error_email_in_use');
      case 'weak-password':
        return currentAccount.t('error_password_length');
      case 'invalid-email':
        return currentAccount.t('error_valid_email');
      case 'too-many-requests':
        return currentAccount.t('error_too_many_requests');
      default:
        return 'Auth error (${e.code}): ${e.message ?? currentAccount.t('error_auth_generic')}';
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;

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
      if (password.length < 6) {
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

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential credential;
      if (_isLogin) {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (name.isNotEmpty) {
          await credential.user?.updateDisplayName(name);
          await credential.user?.reload();
        }
      }

      final user = FirebaseAuth.instance.currentUser ?? credential.user;
      if (user != null) {
        await FirestoreService.loadOrCreateAccount(
          user,
          fallbackName: !_isLogin ? name : null,
          fallbackEmail: email,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => currentAccount.isStaff ? const staff_home.HomePage() : const client_home.HomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapAuthError(e))),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firestore error (${e.code}): ${e.message ?? ''}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Creates and signs into a random realistic account.
  Future<void> _loginAsRandomDefault() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final rng = Random.secure();
      final first = _firstNames[rng.nextInt(_firstNames.length)];
      final last = _lastNames[rng.nextInt(_lastNames.length)];
      final fullName = '$first $last';
      final suffix = 100 + rng.nextInt(9000);
      final randomEmail = '${first.toLowerCase()}.${last.toLowerCase()}$suffix@clinicflow.app';
      const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#';
      final randomPassword = List.generate(14, (_) => chars[rng.nextInt(chars.length)]).join();

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: randomEmail,
        password: randomPassword,
      );
      await credential.user?.updateDisplayName(fullName);
      await credential.user?.reload();

      final user = FirebaseAuth.instance.currentUser ?? credential.user;
      if (user != null) {
        await FirestoreService.loadOrCreateAccount(
          user,
          fallbackName: fullName,
          fallbackEmail: randomEmail,
          seedSampleData: true,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => currentAccount.isStaff ? const staff_home.HomePage() : const client_home.HomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapAuthError(e))),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firestore error (${e.code}): ${e.message ?? ''}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Signs into the fixed default demo account (used when [enableGoogleSignIn] is true).
  Future<void> _loginWithGoogleDemo() async {
    if (!enableGoogleSignIn || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential credential;
      try {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _defaultDemoEmail,
          password: _defaultDemoPassword,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _defaultDemoEmail,
            password: _defaultDemoPassword,
          );
          await credential.user?.updateDisplayName('Jamie Chen');
          await credential.user?.reload();
        } else {
          rethrow;
        }
      }

      final user = FirebaseAuth.instance.currentUser ?? credential.user;
      if (user != null) {
        await FirestoreService.loadOrCreateAccount(
          user,
          fallbackName: 'Jamie Chen',
          fallbackEmail: _defaultDemoEmail,
          isDefaultDemo: true,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => currentAccount.isStaff ? const staff_home.HomePage() : const client_home.HomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapAuthError(e))),
      );
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firestore error (${e.code}): ${e.message ?? ''}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                  style: TextStyle(color: palette.textPrimary),
                  decoration: themedInputDecoration(
                    labelText: currentAccount.t('name'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                style: TextStyle(color: palette.textPrimary),
                decoration: themedInputDecoration(
                  labelText: currentAccount.t('email'),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: TextStyle(color: palette.textPrimary),
                decoration: themedInputDecoration(
                  labelText: currentAccount.t('password'),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(backgroundColor: palette.primary),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isLogin ? currentAccount.t('login') : currentAccount.t('signup')),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _loginAsRandomDefault,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: palette.textSecondary),
                  ),
                  child: Text(
                    currentAccount.t('default_account'),
                    style: TextStyle(color: palette.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : (enableGoogleSignIn ? _loginWithGoogleDemo : () {}),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: palette.textSecondary),
                  ),
                  icon: Icon(Icons.login, color: palette.textPrimary),
                  label: Text(
                    currentAccount.t('login_with_google'),
                    style: TextStyle(color: palette.textPrimary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
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