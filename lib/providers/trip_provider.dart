import 'package:flutter/material.dart';

import '../models/trip_model.dart';
import '../services/firestore_service.dart';

class TripProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  bool getIsLoading() {
    return _isLoading;
  }

  String? getErrorMessage() {
    return _errorMessage;
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Stream<List<TripModel>> getUserTrips(String userId) {
    return _firestoreService.getUserTrips(userId);
  }

  Future<bool> addTrip(TripModel trip) async {
    try {
      setLoading(true);
      _errorMessage = null;

      await _firestoreService.addTrip(trip);

      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create trip. Please try again.';

      setLoading(false);
      return false;
    }
  }

  Future<bool> updateTrip(TripModel trip) async {
    try {
      setLoading(true);
      _errorMessage = null;

      await _firestoreService.updateTrip(trip);

      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update trip. Please try again.';

      setLoading(false);
      return false;
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    try {
      setLoading(true);
      _errorMessage = null;

      await _firestoreService.deleteTrip(tripId);

      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete trip. Please try again.';

      setLoading(false);
      return false;
    }
  }
}