import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  String id;
  String userId;
  String tripName;
  String destination;
  DateTime startDate;
  DateTime endDate;
  double totalBudget;
  double personalBudget;
  int members;
  String notes;
  String imagePath;
  DateTime createdAt;

  TripModel({
    required this.id,
    required this.userId,
    required this.tripName,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.totalBudget,
    required this.personalBudget,
    required this.members,
    required this.notes,
    required this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tripName': tripName,
      'destination': destination,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalBudget': totalBudget,
      'personalBudget': personalBudget,
      'members': members,
      'notes': notes,
      'imagePath': imagePath,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TripModel.fromMap(String documentId, Map<String, dynamic> data) {
    return TripModel(
      id: documentId,
      userId: data['userId'] ?? '',
      tripName: data['tripName'] ?? '',
      destination: data['destination'] ?? '',
      startDate: convertTimestampToDate(data['startDate']),
      endDate: convertTimestampToDate(data['endDate']),
      totalBudget: convertToDouble(data['totalBudget']),
      personalBudget: convertToDouble(data['personalBudget']),
      members: convertToInt(data['members']),
      notes: data['notes'] ?? '',
      imagePath: data['imagePath'] ?? 'assets/images/trip_cover_1.png',
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

  static int convertToInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}