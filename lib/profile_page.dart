import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moch_mobile/login_page.dart';
import 'package:moch_mobile/shared_preferences_util.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: TextButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 24)),
                backgroundColor: MaterialStateProperty.all(Colors.cyan),
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            child: const Text('התנתק'),
            onPressed: () async => {
                  await SharedPreferencesUtil.clearLoginData(),
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  )
                }));
  }
}
