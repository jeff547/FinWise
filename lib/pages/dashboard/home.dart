import 'package:fin_wise/pages/title.dart';
import 'package:fin_wise/services/socials_sign_in.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: const LogOut(),
        ),
      ),
    );
  }
}

class LogOut extends StatelessWidget {
  const LogOut({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            AuthService().signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const TitlePage(),
              ),
            );
          },
          child: const Text(
            'Sign Out',
          ),
        ),
      ),
    );
  }
}
