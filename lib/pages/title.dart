import 'package:fin_wise/pages/login.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class TitlePage extends StatefulWidget {
  const TitlePage({super.key});

  @override
  State<TitlePage> createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {
  Route _createFadeTransitionRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(seconds: 2),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginPage(),
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

    if (mounted) {
      Timer(const Duration(milliseconds: 1000), () {
        Navigator.pushReplacement(context, _createFadeTransitionRoute());
      });
    }
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
