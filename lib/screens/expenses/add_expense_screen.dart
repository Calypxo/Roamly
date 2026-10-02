import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/expense_model.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final TripModel trip;
  final ExpenseModel? expenseToEdit;

  const AddExpenseScreen({
    super.key,
    required this.trip,
    this.expenseToEdit,
  });

  @override
  State<AddExpenseScreen> createState() {
    return _AddExpenseScreenState();
  }
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedCategory = 'Food';
  String _selectedExpenseType = 'Personal';
  DateTime? _selectedDate;

  final DateFormat _dateFormat = DateFormat('MMMM d, yyyy');

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();

    if (widget.expenseToEdit != null) {
      loadExpenseData();
    }
  }

  void loadExpenseData() {
    ExpenseModel expense;

    expense = widget.expenseToEdit!;

    _titleController.text = expense.title;
    _amountController.text = expense.amount.toStringAsFixed(0);
    _notesController.text = expense.notes;
    _selectedCategory = expense.category;
    _selectedExpenseType = expense.expenseType;
    _selectedDate = expense.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  bool isEditMode() {
    if (widget.expenseToEdit == null) {
      return false;
    }

    return true;
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }

    return _dateFormat.format(date);
  }

  Future<void> pickExpenseDate() async {
    DateTime initialDate;

    if (_selectedDate == null) {
      initialDate = DateTime.now();
    } else {
      initialDate = _selectedDate!;
    }

    DateTime? pickedDate;

    pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void selectExpenseType(String expenseType) {
    setState(() {
      _selectedExpenseType = expenseType;
    });
  }

  Future<void> saveExpense() async {
    bool isValid;

    isValid = _formKey.currentState!.validate();

    if (isValid == false) {
      return;
    }

    if (_selectedDate == null) {
      showErrorDialog('Please select a date.');
      return;
    }

    AuthProvider authProvider;
    ExpenseProvider expenseProvider;

    authProvider = context.read<AuthProvider>();
    expenseProvider = context.read<ExpenseProvider>();

    final user = authProvider.getCurrentUser();

    if (user == null) {
      showErrorDialog('No logged-in user found.');
      return;
    }

    double amount;

    amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    ExpenseModel expense;

    if (isEditMode()) {
      expense = ExpenseModel(
        id: widget.expenseToEdit!.id,
        tripId: widget.trip.id,
        userId: user.uid,
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        expenseType: _selectedExpenseType,
        date: _selectedDate!,
        notes: _notesController.text.trim(),
        createdAt: widget.expenseToEdit!.createdAt,
      );
    } else {
      expense = ExpenseModel(
        id: '',
        tripId: widget.trip.id,
        userId: user.uid,
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        expenseType: _selectedExpenseType,
        date: _selectedDate!,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );
    }

    bool success;

    if (isEditMode()) {
      success = await expenseProvider.updateExpense(expense);
    } else {
      success = await expenseProvider.addExpense(expense);
    }

    if (!mounted) {
      return;
    }

    if (success == true) {
      showSuccessDialog();
    } else {
      showErrorDialog(expenseProvider.getErrorMessage());
    }
  }

  void showSuccessDialog() {
    String title;
    String message;

    if (isEditMode()) {
      title = 'Expense Updated!';
      message = 'Your expense has been updated successfully.';
    } else {
      title = 'Expense Saved!';
      message = 'Your expense has been added to this trip.';
    }

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
              'assets/images/success_duck.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.successGreen,
                  size: 55,
                );
              },
            ),
          ),
        ),
      ),
      title: title,
      desc: message,
      btnOkText: 'Continue',
      btnOkColor: AppColors.brown,
      btnOkOnPress: () {
        Navigator.pop(context);
      },
    ).show();
  }

  void showErrorDialog(String? message) {
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

  String? validateRequiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required.';
    }

    return null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required.';
    }

    double? amount;

    amount = double.tryParse(value.trim());

    if (amount == null) {
      return 'Enter a valid amount.';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    ExpenseProvider expenseProvider;

    expenseProvider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 18, 30, 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildTopBar(),
                const SizedBox(height: 26),
                buildExpenseTextField(
                  label: 'Expense Title',
                  hintText: 'eg Dinner, Coffee, Van Share',
                  icon: Icons.receipt_long_outlined,
                  controller: _titleController,
                  validator: validateRequiredField,
                ),
                const SizedBox(height: 24),
                buildExpenseTextField(
                  label: 'Amount',
                  hintText: 'eg 500',
                  icon: Icons.account_balance_wallet_outlined,
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  validator: validateAmount,
                ),
                const SizedBox(height: 26),
                buildExpenseTypeSection(),
                const SizedBox(height: 26),
                buildCategorySection(),
                const SizedBox(height: 26),
                buildDateField(),
                const SizedBox(height: 24),
                buildExpenseTextField(
                  label: 'Notes (Optional)',
                  hintText: 'eg Paid for van fare',
                  icon: Icons.notes_rounded,
                  controller: _notesController,
                  maxLines: 6,
                ),
                const SizedBox(height: 34),
                buildSaveButton(expenseProvider.getIsLoading()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTopBar() {
    String title;

    if (isEditMode()) {
      title = 'Edit Expense';
    } else {
      title = 'Add Expense';
    }

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
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
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

  Widget buildExpenseTextField({
    required String label,
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 0,
          child: Icon(
            icon,
            color: AppColors.brown,
            size: 0,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.brown,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                validator: validator,
                maxLines: maxLines,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.brown,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.lightText,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  filled: true,
                  fillColor: AppColors.expenseField,
                  errorStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.errorRed,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.brown,
                      width: 1.2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.errorRed,
                      width: 1.2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.errorRed,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildExpenseTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Expense Type',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildExpenseTypeCard(
                expenseType: 'Personal',
                icon: Icons.person_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildExpenseTypeCard(
                expenseType: 'Group',
                icon: Icons.groups_2_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildExpenseTypeCard({
    required String expenseType,
    required IconData icon,
  }) {
    bool isSelected;

    isSelected = _selectedExpenseType == expenseType;

    return GestureDetector(
      onTap: () {
        selectExpenseType(expenseType);
      },
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.activeCategory
              : AppColors.inactiveCategory,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.brown,
              size: 30,
            ),
            const SizedBox(height: 6),
            Text(
              expenseType,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.brown,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Category',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildCategoryCard(
                category: 'Food',
                icon: Icons.restaurant_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildCategoryCard(
                category: 'Transport',
                icon: Icons.directions_car_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildCategoryCard(
                category: 'Stay',
                icon: Icons.bed_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildCategoryCard(
                category: 'Other',
                icon: Icons.more_horiz_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCategoryCard({
    required String category,
    required IconData icon,
  }) {
    bool isSelected;

    isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        selectCategory(category);
      },
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.activeCategory
              : AppColors.inactiveCategory,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.brown,
              size: 30,
            ),
            const SizedBox(height: 6),
            Text(
              category,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.brown,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: pickExpenseDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.expenseField,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              formatDate(_selectedDate),
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.brown,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSaveButton(bool isLoading) {
    String buttonText;

    if (isEditMode()) {
      buttonText = 'Update Expense';
    } else {
      buttonText = 'Save Expense';
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bigCard,
          foregroundColor: AppColors.brown,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            color: AppColors.brown,
            strokeWidth: 2.4,
          ),
        )
            : Text(
          buttonText,
          style: const TextStyle(
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
}