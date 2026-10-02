import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/trip_model.dart';
import '../models/expense_model.dart';
import '../models/itinerary_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference getTripsCollection() {
    return _firestore.collection('trips');
  }

  Future<void> addTrip(TripModel trip) async {
    CollectionReference tripsCollection;

    tripsCollection = getTripsCollection();

    await tripsCollection.add(
      trip.toMap(),
    );
  }

  Stream<List<TripModel>> getUserTrips(String userId) {
    CollectionReference tripsCollection;

    tripsCollection = getTripsCollection();

    return tripsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      List<TripModel> trips = [];

      for (var document in snapshot.docs) {
        Map<String, dynamic> data;

        data = document.data() as Map<String, dynamic>;

        TripModel trip;

        trip = TripModel.fromMap(
          document.id,
          data,
        );

        trips.add(trip);
      }

      trips.sort((firstTrip, secondTrip) {
        return secondTrip.createdAt.compareTo(firstTrip.createdAt);
      });

      return trips;
    });
  }

  Future<void> updateTrip(TripModel trip) async {
    CollectionReference tripsCollection;

    tripsCollection = getTripsCollection();

    await tripsCollection.doc(trip.id).update(
      trip.toMap(),
    );
  }

  Future<void> deleteTrip(String tripId) async {
    CollectionReference tripsCollection;

    tripsCollection = getTripsCollection();

    await tripsCollection.doc(tripId).delete();
  }

  CollectionReference getExpensesCollection() {
    return _firestore.collection('expenses');
  }

  Future<void> addExpense(ExpenseModel expense) async {
    CollectionReference expensesCollection;

    expensesCollection = getExpensesCollection();

    await expensesCollection.add(
      expense.toMap(),
    );
  }

  Stream<List<ExpenseModel>> getTripExpenses(String tripId, String userId) {
    CollectionReference expensesCollection;

    expensesCollection = getExpensesCollection();

    return expensesCollection
        .where('tripId', isEqualTo: tripId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      List<ExpenseModel> expenses = [];

      for (var document in snapshot.docs) {
        Map<String, dynamic> data;

        data = document.data() as Map<String, dynamic>;

        ExpenseModel expense;

        expense = ExpenseModel.fromMap(
          document.id,
          data,
        );

        expenses.add(expense);
      }

      expenses.sort((firstExpense, secondExpense) {
        return secondExpense.createdAt.compareTo(firstExpense.createdAt);
      });

      return expenses;
    });
  }

  Stream<List<ExpenseModel>> getUserExpenses(String userId) {
    CollectionReference expensesCollection;

    expensesCollection = getExpensesCollection();

    return expensesCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      List<ExpenseModel> expenses = [];

      for (var document in snapshot.docs) {
        Map<String, dynamic> data;

        data = document.data() as Map<String, dynamic>;

        ExpenseModel expense;

        expense = ExpenseModel.fromMap(
          document.id,
          data,
        );

        expenses.add(expense);
      }

      expenses.sort((firstExpense, secondExpense) {
        return secondExpense.createdAt.compareTo(firstExpense.createdAt);
      });

      return expenses;
    });
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    CollectionReference expensesCollection;

    expensesCollection = getExpensesCollection();

    await expensesCollection.doc(expense.id).update(
      expense.toMap(),
    );
  }

  Future<void> deleteExpense(String expenseId) async {
    CollectionReference expensesCollection;

    expensesCollection = getExpensesCollection();

    await expensesCollection.doc(expenseId).delete();
  }

  CollectionReference getItineraryCollection() {
    return _firestore.collection('itineraries');
  }

  Future<void> addItinerary(ItineraryModel itinerary) async {
    CollectionReference itineraryCollection;

    itineraryCollection = getItineraryCollection();

    await itineraryCollection.add(
      itinerary.toMap(),
    );
  }

  Stream<List<ItineraryModel>> getTripItineraries(String tripId, String userId) {
    CollectionReference itineraryCollection;

    itineraryCollection = getItineraryCollection();

    return itineraryCollection
        .where('tripId', isEqualTo: tripId)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      List<ItineraryModel> itineraries = [];

      for (var document in snapshot.docs) {
        Map<String, dynamic> data;

        data = document.data() as Map<String, dynamic>;

        ItineraryModel itinerary;

        itinerary = ItineraryModel.fromMap(
          document.id,
          data,
        );

        itineraries.add(itinerary);
      }

      itineraries.sort((firstItinerary, secondItinerary) {
        int dateCompare;

        dateCompare = firstItinerary.date.compareTo(secondItinerary.date);

        if (dateCompare != 0) {
          return dateCompare;
        }

        return firstItinerary.createdAt.compareTo(secondItinerary.createdAt);
      });

      return itineraries;
    });
  }

  Future<void> updateItinerary(ItineraryModel itinerary) async {
    CollectionReference itineraryCollection;

    itineraryCollection = getItineraryCollection();

    await itineraryCollection.doc(itinerary.id).update(
      itinerary.toMap(),
    );
  }

  Future<void> deleteItinerary(String itineraryId) async {
    CollectionReference itineraryCollection;

    itineraryCollection = getItineraryCollection();

    await itineraryCollection.doc(itineraryId).delete();
  }

}