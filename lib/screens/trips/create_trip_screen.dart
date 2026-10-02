import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../widgets/custom_text_field.dart';

class CreateTripScreen extends StatefulWidget {
  final TripModel? tripToEdit;

  const CreateTripScreen({
    super.key,
    this.tripToEdit,
  });

  @override
  State<CreateTripScreen> createState() {
    return _CreateTripScreenState();
  }
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _personalBudgetController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  int _members = 1;

  String _selectedImagePath = 'assets/images/trip_cover_1.png';

  final DateFormat _dateFormat = DateFormat('MMMM d, yyyy');

  final List<String> _coverImages = [
    'assets/images/trip_cover_1.png',
    'assets/images/trip_cover_2.png',
    'assets/images/trip_cover_3.png',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.tripToEdit != null) {
      loadTripData();
    }
  }

  void loadTripData() {
    TripModel trip;

    trip = widget.tripToEdit!;

    _tripNameController.text = trip.tripName;
    _destinationController.text = trip.destination;
    _budgetController.text = trip.totalBudget.toStringAsFixed(0);
    _personalBudgetController.text = trip.personalBudget.toStringAsFixed(0);
    _notesController.text = trip.notes;

    _startDate = trip.startDate;
    _endDate = trip.endDate;
    _members = trip.members;

    if (trip.imagePath.trim().isNotEmpty) {
      _selectedImagePath = trip.imagePath;
    }
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _personalBudgetController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  bool isEditMode() {
    if (widget.tripToEdit == null) {
      return false;
    }

    return true;
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    return _dateFormat.format(date);
  }

  Future<void> pickStartDate() async {
    DateTime initialDate;

    if (_startDate == null) {
      initialDate = DateTime.now();
    } else {
      initialDate = _startDate!;
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
        _startDate = pickedDate;

        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> pickEndDate() async {
    DateTime initialDate;

    if (_endDate == null) {
      if (_startDate == null) {
        initialDate = DateTime.now();
      } else {
        initialDate = _startDate!;
      }
    } else {
      initialDate = _endDate!;
    }

    DateTime firstAllowedDate;

    if (_startDate == null) {
      firstAllowedDate = DateTime(2020);
    } else {
      firstAllowedDate = _startDate!;
    }

    DateTime? pickedDate;

    pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  void increaseMembers() {
    setState(() {
      _members = _members + 1;
    });
  }

  void decreaseMembers() {
    if (_members <= 1) {
      return;
    }

    setState(() {
      _members = _members - 1;
    });
  }

  void showCoverPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Trip Cover',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.brown,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: buildCoverOption(
                      context,
                      _coverImages[0],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildCoverOption(
                      context,
                      _coverImages[1],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: buildCoverOption(
                      context,
                      _coverImages[2],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCoverOption(BuildContext context, String imagePath) {
    bool isSelected;

    isSelected = _selectedImagePath == imagePath;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImagePath = imagePath;
        });

        Navigator.pop(context);
      },
      child: Container(
        height: 95,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.brown : AppColors.borderPeach,
            width: isSelected ? 3 : 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Future<void> saveTrip() async {
    bool isValid;

    isValid = _formKey.currentState!.validate();

    if (isValid == false) {
      return;
    }

    if (_startDate == null) {
      showErrorDialog('Please select a start date.');
      return;
    }

    if (_endDate == null) {
      showErrorDialog('Please select an end date.');
      return;
    }

    AuthProvider authProvider;
    TripProvider tripProvider;

    authProvider = context.read<AuthProvider>();
    tripProvider = context.read<TripProvider>();

    final user = authProvider.getCurrentUser();

    if (user == null) {
      showErrorDialog('No logged-in user found.');
      return;
    }

    double budget;
    double personalBudget;

    budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;
    personalBudget = double.tryParse(_personalBudgetController.text.trim()) ?? 0.0;

    TripModel trip;

    if (isEditMode()) {
      trip = TripModel(
        id: widget.tripToEdit!.id,
        userId: user.uid,
        tripName: _tripNameController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        totalBudget: budget,
        personalBudget: personalBudget,
        members: _members,
        notes: _notesController.text.trim(),
        imagePath: _selectedImagePath,
        createdAt: widget.tripToEdit!.createdAt,
      );
    } else {
      trip = TripModel(
        id: '',
        userId: user.uid,
        tripName: _tripNameController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        totalBudget: budget,
        personalBudget: personalBudget,
        members: _members,
        notes: _notesController.text.trim(),
        imagePath: _selectedImagePath,
        createdAt: DateTime.now(),
      );
    }

    bool success;

    if (isEditMode()) {
      success = await tripProvider.updateTrip(trip);
    } else {
      success = await tripProvider.addTrip(trip);
    }

    if (!mounted) {
      return;
    }

    if (success == true) {
      showSuccessDialog();
    } else {
      showErrorDialog(tripProvider.getErrorMessage());
    }
  }

  void showSuccessDialog() {
    String title;
    String message;

    if (isEditMode()) {
      title = 'Trip Updated!';
      message = 'Your trip details have been updated successfully.';
    } else {
      title = 'Trip Created!';
      message = 'Your new trip has been saved successfully.';
    }

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
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

  String? validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Budget is required.';
    }

    double? budget;

    budget = double.tryParse(value.trim());

    if (budget == null) {
      return 'Enter a valid amount.';
    }

    if (budget <= 0) {
      return 'Budget must be greater than 0.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    TripProvider tripProvider;

    tripProvider = context.watch<TripProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildTopBar(),
                const SizedBox(height: 18),
                buildCoverImage(),
                const SizedBox(height: 28),
                buildTextFieldWithIcon(
                  icon: Icons.badge_outlined,
                  label: 'Trip Name',
                  hintText: 'e.g. Baguio Adventure',
                  controller: _tripNameController,
                  validator: validateRequiredField,
                ),
                const SizedBox(height: 18),
                buildTextFieldWithIcon(
                  icon: Icons.location_on_rounded,
                  label: 'Destination',
                  hintText: 'e.g. Baguio City, Philippines',
                  controller: _destinationController,
                  validator: validateRequiredField,
                ),
                const SizedBox(height: 18),
                buildDateField(
                  icon: Icons.calendar_month_rounded,
                  label: 'Start Date',
                  dateText: formatDate(_startDate),
                  onTap: pickStartDate,
                ),
                const SizedBox(height: 18),
                buildDateField(
                  icon: Icons.calendar_month_rounded,
                  label: 'End Date',
                  dateText: formatDate(_endDate),
                  onTap: pickEndDate,
                ),
                const SizedBox(height: 18),
                buildTextFieldWithIcon(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Group Trip Budget',
                  hintText: 'e.g. 20000',
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  validator: validateBudget,
                ),
                const SizedBox(height: 18),
                buildTextFieldWithIcon(
                  icon: Icons.savings_outlined,
                  label: 'Personal Trip Budget',
                  hintText: 'e.g. 5000',
                  controller: _personalBudgetController,
                  keyboardType: TextInputType.number,
                  validator: validateBudget,
                ),
                const SizedBox(height: 18),
                buildMembersCounter(),
                const SizedBox(height: 18),
                buildTextFieldWithIcon(
                  icon: Icons.notes_rounded,
                  label: 'Notes (Optional)',
                  hintText: 'Add notes about your trip.',
                  controller: _notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: 28),
                buildSaveButton(tripProvider.getIsLoading()),
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
      title = 'Edit Trip';
    } else {
      title = 'Create New Trip';
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

  Widget buildCoverImage() {
    return GestureDetector(
      onTap: showCoverPicker,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              image: DecorationImage(
                image: AssetImage(_selectedImagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: 62,
            width: 62,
            decoration: const BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: AppColors.buttonPink,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextFieldWithIcon({
    required IconData icon,
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: hintText,
      icon: icon,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      fillColor: AppColors.expenseField,
      textColor: AppColors.brown,
      hintColor: AppColors.lightText,
      labelColor: AppColors.brown,
      iconColor: AppColors.brown,
    );
  }

  Widget buildDateField({
    required IconData icon,
    required String label,
    required String dateText,
    required VoidCallback onTap,
  }) {
    String displayText;

    if (dateText.isEmpty) {
      displayText = 'Select date';
    } else {
      displayText = dateText;
    }

    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
            text: displayText,
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppColors.brown,
            ),
            filled: true,
            fillColor: AppColors.expenseField,
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.lightText,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: const BorderSide(
                color: AppColors.brown,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMembersCounter() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 42,
          child: Icon(
            Icons.groups_2_outlined,
            color: AppColors.brown,
            size: 34,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Number of Members',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          height: 54,
          width: 120,
          decoration: BoxDecoration(
            color: AppColors.expenseField,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: decreaseMembers,
                child: const Icon(
                  Icons.remove_rounded,
                  color: AppColors.brown,
                ),
              ),
              Text(
                _members.toString(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.brown,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: increaseMembers,
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.brown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSaveButton(bool isLoading) {
    String buttonText;

    if (isEditMode()) {
      buttonText = 'Update Trip';
    } else {
      buttonText = 'Create Trip';
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : saveTrip,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bigCard,
          foregroundColor: AppColors.brown,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: AppColors.brown,
            strokeWidth: 2.5,
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