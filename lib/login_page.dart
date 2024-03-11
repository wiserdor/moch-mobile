// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lottery_checker.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LotteryChecker lotteryChecker = LotteryChecker();

  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _partnerIdController = TextEditingController();
  final _passwordController = TextEditingController();

  bool error = false;
  bool isLoading = false;
  var errMsg = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background Color
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: <Widget>[
              // Add the logo
              Image.asset(
                'assets/logo.png', // Replace with your logo file path
                height: 100,
                width: 100,
              ),

              // Add a SizedBox for gap between the logo and the first text input
              const SizedBox(height: 32),
              Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: _idController,
                    enabled: !isLoading,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      labelText: 'תעודת זהות',
                      hintStyle: const TextStyle(
                          color: Color(0xFF333333)), // Text Color
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2), // Primary Color
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'תעודת זהות שלך';
                      }
                      // should be only numbers
                      if (int.tryParse(value) == null) {
                        return 'תעודת הזהות צריכה להיות מספר';
                      }

                      return null;
                    },
                  )),
              const SizedBox(height: 16),
              Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'סיסמא',
                      hintStyle: const TextStyle(
                          color: Color(0xFF333333)), // Text Color
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2), // Primary Color
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                    obscureText: true,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'אנא הכנס סיסמא';
                      }

                      return null;
                    },
                  )),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: const Color(0xFFFFFFFF),
                  textStyle: const TextStyle(
                    fontSize: 18,
                  ),
                  minimumSize: const Size(
                      double.infinity, 0), // Set the width to maximum available
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _login();
                        }
                      },
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Color(0xFFFFFFFF)) // Accent Color
                    : const Text('התחבר'),
              ),
              // if error should show error message
              const SizedBox(height: 8),
              if (error)
                Text(
                  errMsg,
                  style:
                      const TextStyle(color: Color(0xFFF44336)), // Error Color
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    // try login 3 times if login succeed but get data not
    LoginStatusType ok = LoginStatusType.loginFailed;
    for (int i = 0; i < 3; i++) {
      ok = await lotteryChecker.checkLottery(
          userId: _idController.text,
          userPartnerId: _partnerIdController.text,
          userPassword: _passwordController.text);

      if (ok == LoginStatusType.loginSuccess ||
          ok == LoginStatusType.loginFailed) {
        break;
      }

      // timeout between tries
      await Future.delayed(const Duration(seconds: 2));
    }

    if (ok != LoginStatusType.loginSuccess) {
      if (ok == LoginStatusType.getDataFailed) {
        setState(() {
          error = true;
          errMsg =
              "החיבור בוצע אך לא הצלחנו לקבל נתונים מהשרת, אנא נסה שוב מאוחר יותר";
          isLoading = false;
        });
      }

      if (ok == LoginStatusType.loginFailed) {
        setState(() {
          error = true;
          errMsg = "תעודת זהות או סיסמא שגויים";
          isLoading = false;
        });
      }

      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('userId', _idController.text);
    await prefs.setString('userPartnerId', _partnerIdController.text);
    await prefs.setString('userPassword', _passwordController.text);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
    );
  }
}
