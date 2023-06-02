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
            child: Text('התנתק'),
            onPressed: () async => {
                  await SharedPreferencesUtil.clear(),
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  )
                }));
  }
}
