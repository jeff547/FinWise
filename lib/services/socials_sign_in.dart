import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twitter_login/twitter_login.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
      if (user != null) {
        log(user.toString());
      }
    });
  }

  User? get user => _user;
  Stream<User?> get userChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      log('Sign in Successful');
      UserCredential? cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred;
    } on Exception catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<String> createNewUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
  }) async {
    if (password != confirmPassword) {
      return 'Passwords do not match!';
    }
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        name.isEmpty) {
      return ('All fields must be filled!');
    }
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _auth.currentUser!.updateDisplayName(name);
      log('Account creation successful');
      return 'Account creation successful!';
    } on Exception catch (e) {
      log(e.toString());
      return e.toString();
    }
  }

  void signOut() async {
    await _auth.signOut();
  }

  Future<UserCredential?> signinWithGoogle() async {
    try {
      final GoogleSignInAccount? user = await GoogleSignIn().signIn();
      if (user == null) {
        log('Sign In cancelled');
        return null;
      }
      final GoogleSignInAuthentication auth = await user.authentication;

      final googleAuthCredential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      return await _auth.signInWithCredential(googleAuthCredential);
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      log('Unexpected error: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(
                loginResult.accessToken!.tokenString);

        return await _auth.signInWithCredential(facebookAuthCredential);
      } else {
        print('Facebook login failed: ${loginResult.message}');
        return null;
      }
    } catch (e) {
      print('Error during Facebook login: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithTwitter() async {
    const String apiKey = 'REMOVED';
    const String apiSecretKey =
        'REMOVED';
    const redirectURI = 'REMOVED';

    try {
      final twitterLogin = TwitterLogin(
        apiKey: apiKey,
        apiSecretKey: apiSecretKey,
        redirectURI: redirectURI,
      );

      final authResult = await twitterLogin.login();

      final twitterAuthCredential = TwitterAuthProvider.credential(
        accessToken: authResult.authToken!,
        secret: authResult.authTokenSecret!,
      );

      return await _auth.signInWithCredential(twitterAuthCredential);
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      log('Unexpected error: $e');
      return null;
    }
  }

  Future<void> linkWithCredential(AuthCredential credential) async {
    try {
      await _auth.currentUser?.linkWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "provider-already-linked":
          log("The provider has already been linked to the user.");
          break;
        case "invalid-credential":
          log("The provider's credential is not valid.");
          break;
        case "credential-already-in-use":
          log("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        default:
          log("Unknown error.");
      }
    }
  }
}
