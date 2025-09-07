import 'package:fin_wise/components.dart';
import 'package:fin_wise/pages/dashboard/home.dart';
import 'package:fin_wise/services/user_provider.dart';
import 'package:fin_wise/pages/user%20auth/forgot_password.dart';
import 'package:fin_wise/pages/user%20auth/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromRGBO(23, 178, 255, 1),
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 20, right: 20, bottom: 40),
                  child: Text(
                    'Welcome Back!\nGlad to see you again!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      textStyle: const TextStyle(
                        height: 1.7,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Flexible(
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
                        child: TextInputForm(
                          controller: _emailController,
                          hintText: 'Enter your email',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 25.0,
                          left: 25,
                          right: 25,
                        ),
                        child: TextInputForm(
                          controller: _passwordController,
                          hintText: 'Enter your password',
                          blurText: true,
                        ),
                      ),
                      Align(
                        widthFactor: 2.3,
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ResetPasswordPage(),
                                ),
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
                            onPressed: () async {
                              try {
                                if (await authService
                                        .signInWithEmailAndPassword(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    ) !=
                                    null) {
                                  if (!context.mounted) return;
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  duration: const Duration(seconds: 2),
                                  content: Text(e.toString()),
                                ));
                              }
                            },
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
                            onPressed: () async {
                              UserCredential? cred =
                                  await authService.signInWithFacebook();
                              if (context.mounted) {
                                if (cred != null) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                  );
                                } else {
                                  _showSignInErrorDialog(context);
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.facebook,
                              color: Colors.blue,
                              size: 50,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              UserCredential? cred =
                                  await authService.signinWithGoogle();
                              if (context.mounted) {
                                if (cred != null) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                  );
                                } else {
                                  _showSignInErrorDialog(context);
                                }
                              }
                            },
                            icon: Image.asset(
                              'lib/assets/google.png',
                              width: 40,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              UserCredential? cred =
                                  await authService.signInWithTwitter();
                              if (context.mounted) {
                                if (cred != null) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                  );
                                } else {
                                  _showSignInErrorDialog(context);
                                }
                              }
                            },
                            icon: Image.asset(
                              'lib/assets/twitter.png',
                              width: 50,
                            ),
                          )
                        ],
                      ),
                      const CreateNewAccount(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateNewAccount extends StatelessWidget {
  const CreateNewAccount({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 65, bottom: 30),
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
            )
          ],
        ),
      ),
    );
  }
}

void _showSignInErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text("Sign-In Error"),
        content: Text("An error occurred while signing in. Please try again."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      );
    },
  );
}
