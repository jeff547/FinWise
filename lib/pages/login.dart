import 'package:fin_wise/pages/user%20auth/forgot_password.dart';
import 'package:fin_wise/pages/user%20auth/signin.dart';
import 'package:fin_wise/pages/user%20auth/signup.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Align(
            alignment: Alignment(0, -0.1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'stocks',
                  child: Image(
                    image: AssetImage('lib/assets/stocks.png'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'FinWise',
                  style: TextStyle(
                    height: 1,
                    color: Colors.black,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 240,
                  height: 30,
                  child: Text(
                    'Stay in control of your money. Track, manage, and grow your wealth with ease.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                SignInButton(),
                SignUpButton(),
                ResetPasswordButton()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ResetPasswordButton extends StatelessWidget {
  const ResetPasswordButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ResetPasswordPage()),
        );
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(
            color: Colors.black, fontSize: 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {
  const SignUpButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SignUpPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(180, 50),
          backgroundColor: const Color(0xFFE0E0E0),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(
              color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  const SignInButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const SignInPage()));
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(180, 50),
        backgroundColor: const Color.fromRGBO(23, 178, 255, 1),
      ),
      child: const Text(
        'Log In',
        style: TextStyle(
            color: Colors.black, fontSize: 21, fontWeight: FontWeight.bold),
      ),
    );
  }
}
