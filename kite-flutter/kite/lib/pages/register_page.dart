import 'package:flutter/material.dart';
import 'package:kite/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.message, size: 50),
                const Text(
                  "Kite",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Create an account!",
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 30),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'username',
                                  prefixIcon: Icon(Icons.person_outline),
                                  hintText: "johndoe",
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'username is required!';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                  hintText: "example@kite.com",
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'email is required!';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  hintText: "enter your password",
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'password is required!';
                                  }
                                  if (value.length < 6) {
                                    return 'password must be at least 6 characters!';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: 'confirm password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  hintText: "re-enter your password",
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'please confirm your password!';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'passwords do not match!';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Submit registration logic here
                                  }
                                },
                                child: const Text("sign up"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Pops back to the Login screen
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              child: const Text("Sign in"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
