import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fin_wise/services/models.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user, String uid) async {
    try {
      await db.collection('users').doc(uid).set(user.toJson());
      print('User added successfully');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  Future<void> createTransaction(String userId, TransactionModel trans) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (trans.category == 'Income' || trans.category == 'Investments') {
        await db.collection('users').doc(userId).update(
          {
            'revenue': FieldValue.increment(trans.amount),
            'balance': FieldValue.increment(trans.amount),
          },
        );
      } else {
        await db.collection('users').doc(userId).update({
          'expenses': FieldValue.increment(trans.amount),
          'balance': FieldValue.increment(-trans.amount),
        });
      }
      if (user != null) {
        final userId = user.uid;
        await db
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .add(trans.toJson());
        print('Transaction added for user $userId');
      }
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }
}
