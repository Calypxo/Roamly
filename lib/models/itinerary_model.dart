import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryModel {
  String id;
  String tripId;
  String userId;
  String title;
  String location;
  DateTime date;
  String time;
  String notes;
  DateTime createdAt;

  ItineraryModel({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'userId': userId,
      'title': title,
      'location': location,
      'date': Timestamp.fromDate(date),
      'time': time,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ItineraryModel.fromMap(String documentId, Map<String, dynamic> data) {
    return ItineraryModel(
      id: documentId,
      tripId: data['tripId'] ?? '',
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      date: convertTimestampToDate(data['date']),
      time: data['time'] ?? '',
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
}