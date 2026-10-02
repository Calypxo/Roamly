import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import 'create_trip_screen.dart';
import 'trip_details_screen.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  void goToCreateTrip(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const CreateTripScreen();
        },
      ),
    );
  }

  void goToTripDetails(BuildContext context, TripModel trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return TripDetailsScreen(trip: trip);
        },
      ),
    );
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

  String formatBudget(double budget) {
    NumberFormat formatter;

    formatter = NumberFormat('#,##0');

    return 'Php. ${formatter.format(budget)}';
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider;
    TripProvider tripProvider;

    authProvider = context.watch<AuthProvider>();
    tripProvider = context.watch<TripProvider>();

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
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(),
              const SizedBox(height: 18),
              buildSearchBar(),
              const SizedBox(height: 18),
              buildNewTripButton(context),
              const SizedBox(height: 18),
              Expanded(
                child: StreamBuilder<List<TripModel>>(
                  stream: tripProvider.getUserTrips(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return buildLoadingState();
                    }

                    if (snapshot.hasError) {
                      return buildErrorState();
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return buildEmptyState(context);
                    }

                    List<TripModel> trips;

                    trips = snapshot.data!;

                    return ListView.builder(
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        TripModel trip;

                        trip = trips[index];

                        return buildTripCard(
                          context: context,
                          trip: trip,
                          index: index,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trips',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            letterSpacing: 7,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Your Adventures',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget buildSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderPeach),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.brown),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search trips...',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.lightText,
                fontSize: 15,
                letterSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNewTripButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 48,
        width: 155,
        child: ElevatedButton(
          onPressed: () {
            goToCreateTrip(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bigCard,
            foregroundColor: AppColors.brown,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            '+ New Trip',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTripCard({
    required BuildContext context,
    required TripModel trip,
    required int index,
  }) {
    String imagePath;

    imagePath = trip.imagePath;

    if (imagePath.trim().isEmpty) {
      imagePath = 'assets/images/trip_cover_1.png';
    }

    return GestureDetector(
      onTap: () {
        goToTripDetails(context, trip);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderPeach),
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
                height: 115,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 1, 12, 14),
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
                            fontSize: 20,
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          formatDateRange(trip.startDate, trip.endDate),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.lightText,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.groups_2_outlined,
                        color: AppColors.brown,
                        size: 29,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        trip.members.toString(),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.brown,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatBudget(trip.totalBudget),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.brown,
                          fontSize: 16,
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
      ),
    );
  }

  Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.brown),
    );
  }

  Widget buildErrorState() {
    return const Center(
      child: Text(
        'Unable to load trips.',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.brown,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.tipCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderPeach),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/empty_trip_duck.png',
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 18),
            const Text(
              'No trips yet!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.brown,
                fontSize: 25,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Plan your next adventure and create your first trip.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.brown,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
