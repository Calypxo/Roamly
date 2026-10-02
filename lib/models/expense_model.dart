import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  String id;
  String tripId;
  String userId;
  String title;
  double amount;
  String category;
  String expenseType;
  DateTime date;
  String notes;
  DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.expenseType,
    required this.date,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'expenseType': expenseType,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ExpenseModel.fromMap(String documentId, Map<String, dynamic> data) {
    return ExpenseModel(
      id: documentId,
      tripId: data['tripId'] ?? '',
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      amount: convertToDouble(data['amount']),
      category: data['category'] ?? 'Other',
      expenseType: data['expenseType'] ?? 'Personal',
      date: convertTimestampToDate(data['date']),
      notes: data['notes'] ?? '',
      createdAt: convertTimestampToDate(data['createdAt']),
    );
  }

  static DateTime convertTimestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  static double convertToDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }
}