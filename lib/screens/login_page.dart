import 'package:flutter/material.dart';
import '../models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  Future<void> _ensureDemoUser() async {
    // Initialize users using the UserManager
    await initializeUsers();
  }

  Future<bool> _validateLogin(String username, String password) async {
    final usersList = await UserManager.loadUsers();
    final user = usersList
        .where((u) => u.username == username && u.password == password)
        .firstOrNull;

    if (user != null) {
      // Set current user
      currentUser = user;
      await UserManager.saveCurrentUser(user);
      return true;
    }
    return false;
  }

  void _handleLogin() async {
    await _ensureDemoUser();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final valid = await _validateLogin(username, password);

    if (valid) {
      // Navigate based on user type
      if (mounted) {
        if (currentUser!.userType == 'organizator') {
          Navigator.of(context).pushReplacementNamed('/organizer-dashboard');
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Greška'),
          content: const Text('Neispravno korisničko ime ili lozinka.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('U redu'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _ensureDemoUser();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F3FF),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 370,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_available,
                      color: Colors.deepPurple, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    "Trenuci za pamćenje",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Dobro došli nazad! Molimo prijavite se da nastavite.",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Korisničko ime",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person_outline),
                      hintText: "Unesite korisničko ime",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Lozinka",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      hintText: "Unesite lozinku",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (val) =>
                            setState(() => _rememberMe = val ?? false),
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text("Zapamti me"),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Zaboravili ste lozinku?",
                            style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _handleLogin,
                      child: const Text("Prijavite se"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Nemate nalog?"),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Registrujte se"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
