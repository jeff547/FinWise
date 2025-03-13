import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String? phoneNo;
  final double revenue;
  final double expenses;
  final double balance;
  final double budget;

  const UserModel({
    this.id,
    required this.email,
    required this.name,
    required this.password,
    this.phoneNo,
    this.revenue = 0.0,
    this.expenses = 0.0,
    this.balance = 0.0,
    this.budget = 0.0,
  });

  toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "phoneNo": phoneNo,
      "revenue": revenue,
      "expenses": expenses,
      "balance": balance,
      'budget': budget,
    };
  }
}

class TransactionModel {
  final String category;
  final double amount;
  final Timestamp date;
  final String description;

  TransactionModel({
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      "category": category,
      "amount": amount,
      "date": date,
      "description": description,
    };
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      category: data['category'],
      amount: data['amount'],
      date: data['date'],
      description: data['description'],
    );
  }
}
