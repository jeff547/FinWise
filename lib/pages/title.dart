import 'package:fin_wise/pages/dashboard/home.dart';
import 'package:fin_wise/pages/login.dart';
import 'package:fin_wise/services/userProvider.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class TitlePage extends StatefulWidget {
  const TitlePage({super.key});

  @override
  State<TitlePage> createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {
  Route _createFadeTransitionRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(seconds: 2),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    Timer(const Duration(milliseconds: 1000), () {
      print(authService.user);
      if (authService.user == null) {
        Navigator.pushReplacement(
          context,
          _createFadeTransitionRoute(const LoginPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          _createFadeTransitionRoute(const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromRGBO(23, 178, 255, 1),
      body: Center(
        child: SizedBox(
          width: 400,
          height: 400,
          child: Logo(),
        ),
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Hero(
            tag: 'stocks',
            child: Image(
              image: AssetImage('lib/assets/stocks.png'),
            ),
          ),
          Text(
            'FinWise',
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
