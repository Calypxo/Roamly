import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/itinerary_model.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/itinerary_provider.dart';
import 'add_itinerary_screen.dart';

class ItineraryScreen extends StatelessWidget {
  final TripModel trip;

  const ItineraryScreen({
    super.key,
    required this.trip,
  });

  void goToAddItinerary(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddItineraryScreen(
            trip: trip,
          );
        },
      ),
    );
  }

  void goToEditItinerary(
      BuildContext context,
      ItineraryModel itinerary,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddItineraryScreen(
            trip: trip,
            itineraryToEdit: itinerary,
          );
        },
      ),
    );
  }

  String formatDate(DateTime date) {
    DateFormat formatter;

    formatter = DateFormat('MMMM d, yyyy');

    return formatter.format(date);
  }

  void showDeleteItineraryDialog(
      BuildContext context,
      ItineraryModel itinerary,
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
      title: 'Delete Plan?',
      desc: 'Are you sure you want to delete this itinerary plan? This action cannot be undone.',
      btnCancelText: 'Cancel',
      btnOkText: 'Delete',
      btnOkColor: AppColors.errorRed,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        deleteItinerary(
          context,
          itinerary,
        );
      },
    ).show();
  }

  Future<void> deleteItinerary(
      BuildContext context,
      ItineraryModel itinerary,
      ) async {
    ItineraryProvider itineraryProvider;

    itineraryProvider = context.read<ItineraryProvider>();

    bool success;

    success = await itineraryProvider.deleteItinerary(itinerary.id);

    if (!context.mounted) {
      return;
    }

    if (success == false) {
      showErrorDialog(
        context,
        itineraryProvider.getErrorMessage(),
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
    ItineraryProvider itineraryProvider;

    authProvider = context.watch<AuthProvider>();
    itineraryProvider = context.watch<ItineraryProvider>();

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
        child: StreamBuilder<List<ItineraryModel>>(
          stream: itineraryProvider.getTripItineraries(
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

            List<ItineraryModel> itineraries;

            if (snapshot.hasData) {
              itineraries = snapshot.data!;
            } else {
              itineraries = [];
            }

            return buildMainContent(
              context: context,
              itineraries: itineraries,
            );
          },
        ),
      ),
    );
  }

  Widget buildMainContent({
    required BuildContext context,
    required List<ItineraryModel> itineraries,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 18, 30, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTopBar(context),
          const SizedBox(height: 22),
          buildTripHeader(),
          const SizedBox(height: 24),
          buildSectionHeader(context),
          const SizedBox(height: 12),
          buildItineraryList(
            context,
            itineraries,
          ),
          const SizedBox(height: 18),
          buildAddPlanButton(context),
        ],
      ),
    );
  }

  Widget buildTopBar(BuildContext context) {
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
            'Itinerary',
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
      ],
    );
  }

  Widget buildTripHeader() {
    String imagePath;

    imagePath = trip.imagePath;

    if (imagePath.trim().isEmpty) {
      imagePath = 'assets/images/trip_cover_1.png';
    }

    return Container(
      width: double.infinity,
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
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            child: Align(
              alignment: Alignment.centerLeft,
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
          ),
        ],
      ),
    );
  }

  Widget buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Trip Plans',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildItineraryList(
      BuildContext context,
      List<ItineraryModel> itineraries,
      ) {
    if (itineraries.isEmpty) {
      return buildEmptyItinerary(context);
    }

    return Column(
      children: [
        for (var itinerary in itineraries)
          buildItineraryCard(
            context,
            itinerary,
          ),
      ],
    );
  }

  Widget buildEmptyItinerary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.expenseField,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.fact_check_outlined,
            color: AppColors.brown,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'No plans yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first activity for this trip.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItineraryCard(
      BuildContext context,
      ItineraryModel itinerary,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.expenseField,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          buildDateBox(itinerary.date),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: () {
                goToEditItinerary(
                  context,
                  itinerary,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itinerary.title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.brown,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itinerary.location,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.brown,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    itinerary.time,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.lightText,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            color: AppColors.background,
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppColors.brown,
              size: 18,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                goToEditItinerary(
                  context,
                  itinerary,
                );
              } else if (value == 'delete') {
                showDeleteItineraryDialog(
                  context,
                  itinerary,
                );
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

  Widget buildDateBox(DateTime date) {
    DateFormat dayFormatter;
    DateFormat monthFormatter;

    dayFormatter = DateFormat('d');
    monthFormatter = DateFormat('MMM');

    String dayText;
    String monthText;

    dayText = dayFormatter.format(date);
    monthText = monthFormatter.format(date);

    return Container(
      height: 62,
      width: 58,
      decoration: BoxDecoration(
        color: AppColors.activeCategory,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          Text(
            monthText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAddPlanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          goToAddItinerary(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bigCard,
          foregroundColor: AppColors.brown,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: const Text(
          '+ Add Plan',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 5,
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
        'Unable to load itinerary.',
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