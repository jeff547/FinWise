import 'package:fin_wise/pages/user%20auth/forgot_password.dart';
import 'package:fin_wise/pages/user%20auth/signup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 178, 255, 1),
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 22.0, horizontal: 20),
                child: Text(
                  'Welcome Back!        Glad to see you again',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 20, top: 7, bottom: 8),
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your username or email',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 25.0, left: 25, right: 25),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 20, top: 7, bottom: 8),
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter your password',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      widthFactor: 2.3,
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ResetPasswordPage()),
                            );
                          },
                          child: const Text('Forgot Password?')),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 15.0,
                        left: 25,
                        right: 25,
                        bottom: 40,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: const Padding(
                            padding: EdgeInsets.all(18.0),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 3.0),
                          child: Divider(
                            color: Color(0xFFE0E0E0),
                            thickness: 2,
                            indent: 20,
                            endIndent: 20,
                          ),
                        ),
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                'Or Login with',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 120, 120, 120),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 60,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.facebook,
                            color: Colors.blue,
                            size: 50,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Image.asset('lib/assets/google.png', width: 40),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.apple,
                            size: 50,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 80, bottom: 30),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: "Don't have an Account?  ",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            TextSpan(
                              text: 'Register Now',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 6, 200, 230),
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpPage()),
                                  );
                                },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
