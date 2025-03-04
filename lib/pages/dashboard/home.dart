import 'package:fin_wise/services/socials_sign_in.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              AuthService().signOut();
            },
            child: const Text(
              'Sign Out',
            ),
          ),
        ),
      ),
    );
  }
}
