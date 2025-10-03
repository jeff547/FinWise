import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fin_wise/services/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twitter_login/twitter_login.dart';
import 'db.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userRepository = UserRepository();
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

  Future<String?> createNewUser({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
  }) async {
    final userMod = UserModel(email: email, name: name, password: password);
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
      final authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (authResult.user == null) {
        return null;
      }
      _user = authResult.user;

      await userRepository.createUser(
        userMod,
        _user!.uid,
      );
      await _auth.currentUser!.updateDisplayName(name);
      print('Account creation successful!');
      return 'Account creation successful!';
    } on Exception catch (e) {
      print(e.toString());
      return null;
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
    final String apiKey = dotenv.get('TWITTER_API_KEY');
    final String apiSecretKey = dotenv.get('TWITTER_SECRET_KEY');
    final String redirectURI = dotenv.get('REDIRECT_URI');

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

  Future<void> changePassword(String password) async {
    if (user != null) {
      await _user!.updatePassword(password);
      await user!.reload().then(
        (_) {
          print("Successfully changed password");
        },
      ).catchError((error) {
        print(
          "Password can't be changed$error",
        );
      });
    }
  }

  // Fetch all transactions (no category filter)
  Stream<QuerySnapshot> getAllTransactions(int sort) {
    if (_user == null) {
      // Handle the case when the user is not logged in (return empty or throw error)
      return Stream.empty(); // Or handle differently as needed
    }
    if (sort == 0) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid) // If _user is not null, this will safely work
          .collection('transactions')
          .snapshots();
    } else if (sort == 1) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid) // If _user is not null, this will safely work
          .collection('transactions')
          .orderBy('amount', descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid) // If _user is not null, this will safely work
          .collection('transactions')
          .orderBy('amount', descending: false)
          .snapshots();
    }
  }

// Fetch transactions by category (with category filter)
  Stream<QuerySnapshot> getTransactionsByCategory(String query, int sort) {
    if (_user == null) {
      // Handle the case when the user is not logged in (return empty or throw error)
      return Stream.empty(); // Or handle differently as needed
    }
    if (sort == 0) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('transactions')
          .where(
            Filter.or(
              Filter('category', isEqualTo: query),
              Filter(
                'description',
                isEqualTo: query.toLowerCase(),
              ),
            ),
          )
          .snapshots();
    } else if (sort == 1) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('transactions')
          .where(
            Filter.or(
              Filter('category', isEqualTo: query),
              Filter(
                'description',
                isEqualTo: query.toLowerCase(),
              ),
            ),
          )
          .orderBy('amount', descending: true)
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('transactions')
          .where(
            Filter.or(
              Filter('category', isEqualTo: query),
              Filter(
                'description',
                isEqualTo: query.toLowerCase(),
              ),
            ),
          )
          .orderBy('amount', descending: false)
          .snapshots();
    }
  }

  Future<Map<String, double>> calculateMonthlyRevenueAndExpenses(
      int month, int year) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('transactions')
          .where('date',
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(DateTime(year, month, 1)))
          .where('date',
              isLessThan: Timestamp.fromDate(DateTime(year, month + 1, 1)))
          .get();

      double totalRevenue = 0.0;
      double totalExpenses = 0.0;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        double amount = data['amount'] ?? 0.0;
        String category = data['category'] ?? '';

        if (category == 'Income' || category == 'Investments') {
          totalRevenue += amount;
        } else {
          totalExpenses += amount;
        }
      }

      return {
        'revenue': totalRevenue,
        'expenses': totalExpenses,
      };
    } catch (e) {
      print("Error fetching transactions: $e");
      return {
        'revenue': 0.0,
        'expenses': 0.0,
      };
    }
  }

  Future<Map<String, double>> calculatePercentChange(
      int currentMonth, int currentYear) async {
    try {
      Map<String, double> currentMonthData =
          await calculateMonthlyRevenueAndExpenses(currentMonth, currentYear);

      int previousMonth = currentMonth == 1 ? 12 : currentMonth - 1;
      int previousYear = currentMonth == 1 ? currentYear - 1 : currentYear;

      Map<String, double> previousMonthData =
          await calculateMonthlyRevenueAndExpenses(previousMonth, previousYear);

      double revenueChange = 0.0;
      double expenseChange = 0.0;

      if (previousMonthData['revenue'] != 0.0) {
        revenueChange =
            ((currentMonthData['revenue']! - previousMonthData['revenue']!) /
                    previousMonthData['revenue']!) *
                100;
      } else {
        revenueChange = currentMonthData['revenue']! > 0 ? 100 : 0;
      }

      if (previousMonthData['expenses'] != 0.0) {
        expenseChange =
            ((currentMonthData['expenses']! - previousMonthData['expenses']!) /
                    previousMonthData['expenses']!) *
                100;
      } else {
        expenseChange = currentMonthData['expenses']! > 0 ? 100 : 0;
      }

      return {
        'revenueChange': revenueChange,
        'expenseChange': expenseChange,
      };
    } catch (e) {
      print("Error calculating percent change: $e");
      return {
        'revenueChange': 0.0,
        'expenseChange': 0.0,
      };
    }
  }

  bool _isDeleting = false;

  Future<void> deleteTransaction(String transactionId) async {
    if (_isDeleting) return; // Prevent double deletion
    _isDeleting = true;

    try {
      final userId = _user!.uid;
      final transactionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId);

      final transactionSnapshot = await transactionRef.get();
      if (!transactionSnapshot.exists) {
        _isDeleting = false;
        return;
      }

      final transactionData = transactionSnapshot.data();
      final double amount = transactionData?['amount'] ?? 0.0;
      final String category = transactionData?['category'] ?? '';

      final userFinancialsRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userFinancialsSnapshot = await transaction.get(userFinancialsRef);
        if (!userFinancialsSnapshot.exists) return;

        final double currentBalance =
            userFinancialsSnapshot.data()?['balance'] ?? 0.0;
        final double currentRevenue =
            userFinancialsSnapshot.data()?['revenue'] ?? 0.0;
        final double currentExpenses =
            userFinancialsSnapshot.data()?['expenses'] ?? 0.0;

        double newBalance = currentBalance;
        double newRevenue = currentRevenue;
        double newExpenses = currentExpenses;

        if (category == 'Income' || category == 'Investment') {
          newRevenue = (newRevenue - amount);
          newBalance -= amount;
        } else {
          newExpenses = (newExpenses - amount);
          newBalance += amount;
        }

        transaction.update(
          userFinancialsRef,
          {
            'balance': newBalance,
            'revenue': newRevenue,
            'expenses': newExpenses,
          },
        );

        transaction.delete(transactionRef);
      });
    } catch (e) {
      print("Error deleting transaction: $e");
    } finally {
      _isDeleting = false; // Reset flag after deletion
    }
  }

  Future<Map<String, double>> getCategoryTotals() async {
    final userId = _user!.uid;

    final transactionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions');

    final querySnapshot = await transactionsRef.get();

    Map<String, double> categoryTotals = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final String category = data['category'];
      final double amount = (data['amount'] ?? 0.0).toDouble();

      if (categoryTotals.containsKey(category)) {
        categoryTotals[category] = categoryTotals[category]! + amount;
      } else {
        categoryTotals[category] = amount;
      }
    }

    return categoryTotals;
  }
}

class FinancialsProvider extends ChangeNotifier {
  double balance = 0.0;
  double revenue = 0.0;
  double expenses = 0.0;

  // Stream that listens for changes in the Firestore document
  Stream<DocumentSnapshot> get financialDataStream {
    if (FirebaseAuth.instance.currentUser != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();
    }
    return Stream.empty();
  }

  // Update values based on Firestore data snapshot
  void updateFinancialsFromSnapshot(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;

      // Parse the data and update state
      balance = data['balance'] ?? 0.0;
      revenue = data['revenue'] ?? 0.0;
      expenses = data['expenses'] ?? 0.0;

      notifyListeners();
    }
  }
}
