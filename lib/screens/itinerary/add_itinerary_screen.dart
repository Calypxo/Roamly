import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/itinerary_model.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/itinerary_provider.dart';

class AddItineraryScreen extends StatefulWidget {
  final TripModel trip;
  final ItineraryModel? itineraryToEdit;

  const AddItineraryScreen({
    super.key,
    required this.trip,
    this.itineraryToEdit,
  });

  @override
  State<AddItineraryScreen> createState() {
    return _AddItineraryScreenState();
  }
}

class _AddItineraryScreenState extends State<AddItineraryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;

  final DateFormat _dateFormat = DateFormat('MMMM d, yyyy');

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();

    if (widget.itineraryToEdit != null) {
      loadItineraryData();
    }
  }

  void loadItineraryData() {
    ItineraryModel itinerary;

    itinerary = widget.itineraryToEdit!;

    _titleController.text = itinerary.title;
    _locationController.text = itinerary.location;
    _timeController.text = itinerary.time;
    _notesController.text = itinerary.notes;
    _selectedDate = itinerary.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  bool isEditMode() {
    if (widget.itineraryToEdit == null) {
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

  Future<void> pickItineraryDate() async {
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

  Future<void> saveItinerary() async {
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
    ItineraryProvider itineraryProvider;

    authProvider = context.read<AuthProvider>();
    itineraryProvider = context.read<ItineraryProvider>();

    final user = authProvider.getCurrentUser();

    if (user == null) {
      showErrorDialog('No logged-in user found.');
      return;
    }

    ItineraryModel itinerary;

    if (isEditMode()) {
      itinerary = ItineraryModel(
        id: widget.itineraryToEdit!.id,
        tripId: widget.trip.id,
        userId: user.uid,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        date: _selectedDate!,
        time: _timeController.text.trim(),
        notes: _notesController.text.trim(),
        createdAt: widget.itineraryToEdit!.createdAt,
      );
    } else {
      itinerary = ItineraryModel(
        id: '',
        tripId: widget.trip.id,
        userId: user.uid,
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        date: _selectedDate!,
        time: _timeController.text.trim(),
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );
    }

    bool success;

    if (isEditMode()) {
      success = await itineraryProvider.updateItinerary(itinerary);
    } else {
      success = await itineraryProvider.addItinerary(itinerary);
    }

    if (!mounted) {
      return;
    }

    if (success == true) {
      showSuccessDialog();
    } else {
      showErrorDialog(itineraryProvider.getErrorMessage());
    }
  }

  void showSuccessDialog() {
    String title;
    String message;

    if (isEditMode()) {
      title = 'Itinerary Updated!';
      message = 'Your itinerary activity has been updated successfully.';
    } else {
      title = 'Itinerary Added!';
      message = 'Your activity has been added to this trip.';
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

  @override
  Widget build(BuildContext context) {
    ItineraryProvider itineraryProvider;

    itineraryProvider = context.watch<ItineraryProvider>();

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
                buildItineraryTextField(
                  label: 'Activity Title',
                  hintText: 'eg Burnham Park',
                  controller: _titleController,
                  validator: validateRequiredField,
                ),
                const SizedBox(height: 24),
                buildItineraryTextField(
                  label: 'Location',
                  hintText: 'eg Baguio City',
                  controller: _locationController,
                  validator: validateRequiredField,
                ),
                const SizedBox(height: 24),
                buildDateField(),
                const SizedBox(height: 24),
                buildItineraryTextField(
                  label: 'Time',
                  hintText: 'eg 9:00 AM',
                  controller: _timeController,
                  validator: validateRequiredField,
                ),
                const SizedBox(height: 24),
                buildItineraryTextField(
                  label: 'Notes (Optional)',
                  hintText: 'eg Bring jacket and camera',
                  controller: _notesController,
                  maxLines: 6,
                ),
                const SizedBox(height: 34),
                buildSaveButton(itineraryProvider.getIsLoading()),
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
      title = 'Edit Plan';
    } else {
      title = 'Add Plan';
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

  Widget buildItineraryTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
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
          onTap: pickItineraryDate,
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
      buttonText = 'Update Plan';
    } else {
      buttonText = 'Save Plan';
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : saveItinerary,
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