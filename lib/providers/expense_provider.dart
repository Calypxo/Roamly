import 'package:flutter/material.dart';

import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
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

  Stream<List<ExpenseModel>> getTripExpenses(String tripId, String userId) {
    return _firestoreService.getTripExpenses(tripId, userId);
  }

  Stream<List<ExpenseModel>> getUserExpenses(String userId) {
    return _firestoreService.getUserExpenses(userId);
  }

  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      setLoading(true);
      _errorMessage = null;

      await _firestoreService.addExpense(expense);

      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save expense. Please try again.';

      setLoading(false);
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      setLoading(true);
      _errorMessage = null;

      await _firestoreService.updateExpense(expense);

      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update expense. Please try again.';

      setLoading(false);
      return false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      setLoading(true);
      _errorMessage = null;

      await _firestoreService.deleteExpense(expenseId);

      setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete expense. Please try again.';

      setLoading(false);
      return false;
    }
  }

  double computeTotalSpent(List<ExpenseModel> expenses) {
    double total = 0.0;

    for (var expense in expenses) {
      total = total + expense.amount;
    }

    return total;
  }

  double computeGroupExpenses(List<ExpenseModel> expenses) {
    double total = 0.0;

    for (var expense in expenses) {
      if (expense.expenseType == 'Group') {
        total = total + expense.amount;
      }
    }

    return total;
  }

  double computePersonalExpenses(List<ExpenseModel> expenses) {
    double total = 0.0;

    for (var expense in expenses) {
      if (expense.expenseType == 'Personal') {
        total = total + expense.amount;
      }
    }

    return total;
  }

  double computeTotalGroupBudget({
    required double initialGroupBudget,
    required List<ExpenseModel> expenses,
  }) {
    double groupExpenses;
    double totalGroupBudget;

    groupExpenses = computeGroupExpenses(expenses);
    totalGroupBudget = initialGroupBudget + groupExpenses;

    return totalGroupBudget;
  }

  double computeGroupShare({
    required double initialGroupBudget,
    required int members,
    required List<ExpenseModel> expenses,
  }) {
    double totalGroupBudget;

    totalGroupBudget = computeTotalGroupBudget(
      initialGroupBudget: initialGroupBudget,
      expenses: expenses,
    );

    if (members <= 0) {
      return totalGroupBudget;
    }

    return totalGroupBudget / members;
  }

  double computeRemainingPersonalBudget({
    required double personalBudget,
    required List<ExpenseModel> expenses,
  }) {
    double personalExpenses;
    double remaining;

    personalExpenses = computePersonalExpenses(expenses);
    remaining = personalBudget - personalExpenses;

    return remaining;
  }
}