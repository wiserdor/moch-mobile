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
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: _idController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      labelText: 'תעודת זהות',
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.cyan, width: 2),
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
              Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                    controller: _passwordController,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'תעודת זהות',
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.cyan, width: 2),
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
              TextButton(
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 24)),
                    backgroundColor: MaterialStateProperty.all(Colors.cyan),
                    foregroundColor: MaterialStateProperty.all(Colors.white)),
                onPressed: isLoading
                    ? null
                    : () {
                        // Change this line
                        if (_formKey.currentState!.validate()) {
                          _login();
                        }
                      },
                child: isLoading // And this line
                    ? CircularProgressIndicator() // Add this line
                    : const Text(
                        'התחבר',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
              ),
              // if error should show error message
              if (error)
                Text(
                  errMsg,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 48),
              Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextFormField(
                      controller: _partnerIdController,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: '(לא חובה) תעודת זהות של בן/בת הזוג',
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                      ))),
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
      MaterialPageRoute(builder: (context) => MyApp()),
    );
  }
}
