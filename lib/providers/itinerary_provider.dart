import 'package:flutter/material.dart';

import '../models/itinerary_model.dart';
import '../services/firestore_service.dart';

class ItineraryProvider extends ChangeNotifier {
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

  Stream<List<ItineraryModel>> getTripItineraries(
      String tripId,
      String userId,
      ) {
    return _firestoreService.getTripItineraries(
      tripId,
      userId,
    );
  }

  Future<bool> addItinerary(ItineraryModel itinerary) async {
    try {
      setLoading(true);
      _errorMessage = null;

      await _firestoreService.addItinerary(itinerary);

      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save itinerary. Please try again.';

      setLoading(false);
      return false;
    }
  }

  Future<bool> updateItinerary(ItineraryModel itinerary) async {
    try {
      setLoading(true);
      _errorMessage = null;

      await _firestoreService.updateItinerary(itinerary);

      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update itinerary. Please try again.';

      setLoading(false);
      return false;
    }
  }

  Future<bool> deleteItinerary(String itineraryId) async {
    try {
      setLoading(true);
      _errorMessage = null;

      await _firestoreService.deleteItinerary(itineraryId);

      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete itinerary. Please try again.';

      setLoading(false);
      return false;
    }
  }
}