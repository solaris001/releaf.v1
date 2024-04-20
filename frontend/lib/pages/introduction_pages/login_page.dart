import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:releaf/main.dart';
import 'package:releaf/models/app_colors.dart';


class LoginPage extends StatefulWidget {

  const LoginPage({
    required this.mainPageController,
    super.key,
  });

  final PageController mainPageController;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _passwordVisible = false;

  Future<void> _login() async {

    FocusScope.of(context).unfocus();

    final storedUsername = preferencesInstance.getString('username') ?? '';
    final storedPassword = preferencesInstance.getString('password') ?? '';

    // If the username or password haven't been defined
    if (storedUsername.isEmpty || storedPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              'You have not registered yet! '
                  'Please click on the register button',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
          ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10),
        backgroundColor: AppColors.primaryContainer,
        ),
      );
      FocusScope.of(context).unfocus();

    }

    // If the username and password match the stored ones
    else if (_username == storedUsername && _password == storedPassword) {

      final introDone = preferencesInstance.getBool('intro_page_done') ?? false;

      if (introDone) {
        // Navigate to main screen
        await Navigator.of(context).pushReplacementNamed('/main');

      } else {
        // Navigate to introduction screen
          await Navigator.of(context).pushReplacementNamed('/introduction');
      }
      await preferencesInstance.setBool('logged_in', true);
    }

    // If given username and password are invalid
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Invalid username or password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(10),
          backgroundColor: AppColors.primaryContainer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body:  Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 75,
                    left: 20,
                    right: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/app_logo.svg',
                        height: 100,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onSaved: (value) => _username = value ?? '',
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 50,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_passwordVisible,
                            onSaved: (value) => _password = value ?? '',
                          ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              side: const BorderSide(color: Colors.transparent),
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/password_recovery',
                              );
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Forgot Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _formKey.currentState?.save();
                              _login();
                            }
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors.accentBackgroundColor,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'New to Student Helper?',
                              style: TextStyle(fontSize: 15),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                side: const BorderSide(color: Colors.transparent),
                              ),
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/register',
                                );
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(
                'assets/images/login_page_mascot.svg',
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ],
      ),
    );
  }
}
