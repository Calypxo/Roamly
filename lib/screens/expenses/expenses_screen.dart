import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/expense_model.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import 'add_expense_screen.dart';

class ExpensesScreen extends StatelessWidget {
  final TripModel trip;

  const ExpensesScreen({
    super.key,
    required this.trip,
  });

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  void goToAddExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddExpenseScreen(
            trip: trip,
          );
        },
      ),
    );
  }

  void goToEditExpense(BuildContext context, ExpenseModel expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddExpenseScreen(
            trip: trip,
            expenseToEdit: expense,
          );
        },
      ),
    );
  }

  String formatMoney(double amount) {
    NumberFormat formatter;

    formatter = NumberFormat('#,##0');

    return 'Php. ${formatter.format(amount)}';
  }

  String formatDate(DateTime date) {
    DateFormat formatter;

    formatter = DateFormat('MMMM d, yyyy');

    return formatter.format(date);
  }

  String formatDateRange(DateTime startDate, DateTime endDate) {
    DateFormat formatter;

    formatter = DateFormat('MMMM d');

    String startText;
    String endText;

    startText = formatter.format(startDate);
    endText = formatter.format(endDate);

    return '$startText - $endText';
  }


  void showDeleteExpenseDialog(
      BuildContext context,
      ExpenseModel expense,
      ) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      customHeader: Container(
        height: 80,
        width: 80,
        decoration: const BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Image.asset(
              'assets/images/delete_duck.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.errorRed,
                  size: 55,
                );
              },
            ),
          ),
        ),
      ),
      title: 'Delete Expense?',
      desc: 'Are you sure you want to delete this expense? This action cannot be undone.',
      btnCancelText: 'Cancel',
      btnOkText: 'Delete',
      btnOkColor: AppColors.errorRed,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        deleteExpense(
          context,
          expense,
        );
      },
    ).show();
  }

  Future<void> deleteExpense(
      BuildContext context,
      ExpenseModel expense,
      ) async {
    ExpenseProvider expenseProvider;

    expenseProvider = context.read<ExpenseProvider>();

    bool success;

    success = await expenseProvider.deleteExpense(expense.id);

    if (!context.mounted) {
      return;
    }

    if (success == false) {
      showErrorDialog(
        context,
        expenseProvider.getErrorMessage(),
      );
    }
  }

  void showErrorDialog(BuildContext context, String? message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: 'Action Failed',
      desc: message ?? 'Something went wrong. Please try again.',
      btnOkText: 'Try Again',
      btnOkColor: AppColors.brown,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider;
    ExpenseProvider expenseProvider;

    authProvider = context.watch<AuthProvider>();
    expenseProvider = context.watch<ExpenseProvider>();

    final user = authProvider.getCurrentUser();

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'No logged-in user found.',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<ExpenseModel>>(
          stream: expenseProvider.getTripExpenses(
            trip.id,
            user.uid,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return buildLoadingState();
            }

            if (snapshot.hasError) {
              return buildErrorState();
            }

            List<ExpenseModel> expenses;

            if (snapshot.hasData) {
              expenses = snapshot.data!;
            } else {
              expenses = [];
            }

            double groupExpenses;
            double totalGroupBudget;
            double groupShare;
            double personalExpenses;
            double remainingPersonalBudget;

            groupExpenses = expenseProvider.computeGroupExpenses(expenses);

            totalGroupBudget = expenseProvider.computeTotalGroupBudget(
              initialGroupBudget: trip.totalBudget,
              expenses: expenses,
            );

            groupShare = expenseProvider.computeGroupShare(
              initialGroupBudget: trip.totalBudget,
              members: trip.members,
              expenses: expenses,
            );

            personalExpenses = expenseProvider.computePersonalExpenses(expenses);

            remainingPersonalBudget = expenseProvider.computeRemainingPersonalBudget(
              personalBudget: trip.personalBudget,
              expenses: expenses,
            );

            return buildMainContent(
              context: context,
              expenses: expenses,
              groupExpenses: groupExpenses,
              totalGroupBudget: totalGroupBudget,
              groupShare: groupShare,
              personalExpenses: personalExpenses,
              remainingPersonalBudget: remainingPersonalBudget,
            );
          },
        ),
      ),
    );
  }

  Widget buildMainContent({
    required BuildContext context,
    required List<ExpenseModel> expenses,
    required double groupExpenses,
    required double totalGroupBudget,
    required double groupShare,
    required double personalExpenses,
    required double remainingPersonalBudget,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 18, 32, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitle(context),
          const SizedBox(height: 22),
          buildTripCard(),
          const SizedBox(height: 22),
          buildSectionTitle('Budget Summary'),
          const SizedBox(height: 10),
          buildBudgetSummaryCard(
            groupExpenses: groupExpenses,
            totalGroupBudget: totalGroupBudget,
            groupShare: groupShare,
          ),
          const SizedBox(height: 24),
          buildSectionTitle('Your Spending'),
          const SizedBox(height: 10),
          buildSpendingCard(
            personalExpenses: personalExpenses,
            remainingPersonalBudget: remainingPersonalBudget,
          ),
          const SizedBox(height: 26),
          buildSectionTitle('Recent Expenses'),
          const SizedBox(height: 10),
          buildExpensesList(context, expenses),
          const SizedBox(height: 18),
          buildAddExpenseButton(context),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.brown,
          ),
        ),
        const Expanded(
          child: Text(
            'Trip Budget',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget buildTripCard() {
    String imagePath;

    imagePath = trip.imagePath;

    if (imagePath.trim().isEmpty) {
      imagePath = 'assets/images/trip_cover_1.png';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderPeach,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
            child: Image.asset(
              imagePath,
              height: 105,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 14, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        trip.tripName,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.brown,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.brown,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatDateRange(
                      trip.startDate,
                      trip.endDate,
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.lightText,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.groups_2_outlined,
                      color: AppColors.brown,
                      size: 28,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      trip.members.toString(),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.brown,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatMoney(trip.totalBudget),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.brown,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.brown,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget buildBudgetSummaryCard({
    required double groupExpenses,
    required double totalGroupBudget,
    required double groupShare,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderPeach,
        ),
      ),
      child: Column(
        children: [
          buildBudgetRow(
            label: 'Initial Group Budget',
            value: formatMoney(trip.totalBudget),
          ),
          const SizedBox(height: 12),
          buildBudgetRow(
            label: 'Added Group Expenses',
            value: formatMoney(groupExpenses),
          ),
          const SizedBox(height: 12),
          buildBudgetRow(
            label: 'Total Group Budget',
            value: formatMoney(totalGroupBudget),
          ),
          const SizedBox(height: 12),
          buildBudgetRow(
            label: 'Your Group Share',
            value: formatMoney(groupShare),
          ),
          const SizedBox(height: 12),
          buildBudgetRow(
            label: 'Members',
            value: trip.members.toString(),
          ),
        ],
      ),
    );
  }

  Widget buildBudgetRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget buildSpendingCard({
    required double personalExpenses,
    required double remainingPersonalBudget,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.spendingCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          buildSpendingRow(
            label: 'Personal Budget',
            value: formatMoney(trip.personalBudget),
            isLight: true,
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.background,
          ),
          const SizedBox(height: 8),
          buildSpendingRow(
            label: 'Personal Expenses',
            value: formatMoney(personalExpenses),
            isLight: true,
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.background,
          ),
          const SizedBox(height: 8),
          buildSpendingRow(
            label: 'Remaining Personal Budget',
            value: formatMoney(remainingPersonalBudget),
            isLight: false,
          ),
        ],
      ),
    );
  }

  Widget buildSpendingRow({
    required String label,
    required String value,
    required bool isLight,
  }) {
    Color textColor;

    if (isLight == true) {
      textColor = AppColors.card;
    } else {
      textColor = AppColors.brown;
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget buildExpensesList(
      BuildContext context,
      List<ExpenseModel> expenses,
      ) {
    if (expenses.isEmpty) {
      return buildEmptyExpenses(context);
    }

    return Column(
      children: [
        for (var expense in expenses)
          buildExpenseCard(
            context,
            expense,
          ),
      ],
    );
  }

  Widget buildEmptyExpenses(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.expenseField,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'No expenses yet',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }

  Widget buildExpenseCard(
      BuildContext context,
      ExpenseModel expense,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.expenseField,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                goToEditExpense(context, expense);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.brown,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${expense.expenseType} • ${formatDate(expense.date)}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.brown,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            formatMoney(expense.amount),
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            color: AppColors.background,
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.brown,
              size: 22,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                goToEditExpense(context, expense);
              } else if (value == 'delete') {
                showDeleteExpenseDialog(context, expense);
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.brown,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.errorRed,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  Widget buildAddExpenseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          goToAddExpense(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bigCard,
          foregroundColor: AppColors.brown,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          '+ Add Expense',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.brown,
      ),
    );
  }

  Widget buildErrorState() {
    return const Center(
      child: Text(
        'Unable to load expenses.',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.brown,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}