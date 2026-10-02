import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/expense_model.dart';
import '../../models/trip_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/trip_provider.dart';
import '../trips/create_trip_screen.dart';
import '../trips/trip_details_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onViewAllTrips;

  const HomeScreen({
    super.key,
    this.onViewAllTrips,
  });

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
          return TripDetailsScreen(
            trip: trip,
          );
        },
      ),
    );
  }

  void goToTripsScreen(BuildContext context) {
    if (onViewAllTrips != null) {
      onViewAllTrips!();
    }
  }

  String formatMoney(double amount) {
    NumberFormat formatter;

    formatter = NumberFormat('#,##0');

    return 'Php. ${formatter.format(amount)}';
  }

  String formatDateRange(DateTime startDate, DateTime endDate) {
    DateFormat formatter;

    formatter = DateFormat('MMM d');

    String startText;
    String endText;

    startText = formatter.format(startDate);
    endText = formatter.format(endDate);

    return '$startText - $endText';
  }

  String getDisplayName({
    required String? email,
    required String? displayName,
  }) {
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    if (email != null && email.trim().isNotEmpty) {
      return email.split('@')[0];
    }

    return 'Traveler';
  }

  double computeTotalGroupBudget(List<TripModel> trips) {
    double total = 0.0;

    for (var trip in trips) {
      total = total + trip.totalBudget;
    }

    return total;
  }

  double computeTotalPersonalExpenses(List<ExpenseModel> expenses) {
    double total = 0.0;

    for (var expense in expenses) {
      if (expense.expenseType == 'Personal') {
        total = total + expense.amount;
      }
    }

    return total;
  }

  List<TripModel> getRecentTrips(List<TripModel> trips) {
    List<TripModel> recentTrips = [];

    for (int index = 0; index < trips.length; index++) {
      if (index < 3) {
        recentTrips.add(trips[index]);
      }
    }

    return recentTrips;
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider;
    TripProvider tripProvider;
    ExpenseProvider expenseProvider;

    authProvider = context.watch<AuthProvider>();
    tripProvider = context.watch<TripProvider>();
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<TripModel>>(
          stream: tripProvider.getUserTrips(user.uid),
          builder: (context, tripSnapshot) {
            if (tripSnapshot.connectionState == ConnectionState.waiting) {
              return buildLoadingState();
            }

            if (tripSnapshot.hasError) {
              return buildErrorState();
            }

            List<TripModel> trips;

            if (tripSnapshot.hasData) {
              trips = tripSnapshot.data!;
            } else {
              trips = [];
            }

            return StreamBuilder<List<ExpenseModel>>(
              stream: expenseProvider.getUserExpenses(user.uid),
              builder: (context, expenseSnapshot) {
                List<ExpenseModel> expenses;

                if (expenseSnapshot.hasData) {
                  expenses = expenseSnapshot.data!;
                } else {
                  expenses = [];
                }

                double totalGroupBudget;
                double totalPersonalExpenses;

                totalGroupBudget = computeTotalGroupBudget(trips);
                totalPersonalExpenses = computeTotalPersonalExpenses(expenses);

                return buildDashboardContent(
                  context: context,
                  displayName: getDisplayName(
                    email: user.email,
                    displayName: user.displayName,
                  ),
                  trips: trips,
                  totalGroupBudget: totalGroupBudget,
                  totalPersonalExpenses: totalPersonalExpenses,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildDashboardContent({
    required BuildContext context,
    required String displayName,
    required List<TripModel> trips,
    required double totalGroupBudget,
    required double totalPersonalExpenses,
  }) {
    List<TripModel> recentTrips;

    recentTrips = getRecentTrips(trips);

    return SingleChildScrollView(
      child: Column(
        children: [
          buildHeader(displayName),
          const SizedBox(height: 18),
          buildMainTripCard(context),
          const SizedBox(height: 24),
          buildSummaryCards(
            totalTrips: trips.length,
            totalGroupBudget: totalGroupBudget,
            totalPersonalExpenses: totalPersonalExpenses,
          ),
          const SizedBox(height: 24),
          buildBudgetTipCard(),
          const SizedBox(height: 24),
          buildRecentTripsSection(
            context,
            recentTrips,
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget buildHeader(String displayName) {
    return Stack(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/beach_header.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 150,
          width: double.infinity,
          color: Colors.white.withOpacity(0.10),
        ),
        Positioned(
          left: 24,
          top: 50,
          child: Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.background,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: Transform.scale(
                scale: 1.4,
                child: Image.asset(
                  'assets/images/profile_avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person_rounded,
                      color: AppColors.brown,
                      size: 36,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 105,
          top: 66,
          right: 20,
          child: Text(
            'Welcome back, $displayName',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const Positioned(
          left: 105,
          top: 91,
          child: Text(
            'Ready for your next trip?',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMainTripCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bigCard,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plan your\nnext trip',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.brown,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Create a trip, set a budget, and invite your friends.',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.brown,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 52,
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () {
                      goToCreateTrip(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonPink,
                      foregroundColor: AppColors.brown,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create trip',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.background,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: AppColors.background,
                          size: 17,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 1,
            child: Image.asset(
              'assets/images/travel_car.png',
              height: 150,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.directions_car_filled_rounded,
                  color: AppColors.brown,
                  size: 65,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryCards({
    required int totalTrips,
    required double totalGroupBudget,
    required double totalPersonalExpenses,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: buildSummaryCard(
              color: AppColors.summaryCream,
              imagePath: 'assets/images/camera.png',
              title: 'Total Trips',
              value: totalTrips.toString(),
              subtitle: 'planned',
              fallbackIcon: Icons.map_rounded,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: buildSummaryCard(
              color: AppColors.summaryBlue,
              imagePath: 'assets/images/budget_jar.png',
              title: 'Group Budget',
              value: formatMoney(totalGroupBudget),
              subtitle: 'shared',
              fallbackIcon: Icons.account_balance_wallet_outlined,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: buildSummaryCard(
              color: AppColors.summaryPink,
              imagePath: 'assets/images/receipt.png',
              title: 'Personal Spent',
              value: formatMoney(totalPersonalExpenses),
              subtitle: 'so far',
              fallbackIcon: Icons.receipt_long_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummaryCard({
    required Color color,
    required String imagePath,
    required String title,
    required String value,
    required String subtitle,
    required IconData fallbackIcon,
  }) {
    return Container(
      height: 165,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: AppColors.borderPeach,
          width: 1.4,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 85,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                fallbackIcon,
                color: AppColors.brown,
                size: 36,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBudgetTipCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: CustomPaint(
        painter: DashedBorderPainter(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.tipCard,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/images/lightbulb.png',
                height: 75,
                width: 75,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.brown,
                    size: 48,
                  );
                },
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Roamly Tip',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.brown,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Set your total trip budget first before adding expenses. This helps you see how much your group can still spend.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.brown,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecentTripsSection(
      BuildContext context,
      List<TripModel> recentTrips,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Trips',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.brown,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  goToTripsScreen(context);
                },
                child: const Text(
                  'View all >',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: AppColors.inactiveNav,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentTrips.isEmpty)
            buildEmptyRecentTripsCard(context)
          else
            Column(
              children: [
                for (var trip in recentTrips)
                  buildRecentTripCard(
                    context,
                    trip,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget buildEmptyRecentTripsCard(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/empty_trip_duck.png',
              height: 95,
              width: 110,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.map_outlined,
                  color: AppColors.brown,
                  size: 58,
                );
              },
            ),
            const SizedBox(width: 18),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  goToCreateTrip(context);
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No trips yet.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.brown,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tap here to create your first trip and start planning.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.brown,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRecentTripCard(
      BuildContext context,
      TripModel trip,
      ) {
    String imagePath;

    imagePath = trip.imagePath;

    if (imagePath.trim().isEmpty) {
      imagePath = 'assets/images/trip_cover_1.png';
    }

    return GestureDetector(
      onTap: () {
        goToTripDetails(
          context,
          trip,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.borderPeach,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imagePath,
                height: 75,
                width: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 75,
                    width: 90,
                    color: AppColors.inactiveCategory,
                    child: const Icon(
                      Icons.image_outlined,
                      color: AppColors.brown,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.tripName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.brown,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    trip.destination,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.lightText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatDateRange(
                      trip.startDate,
                      trip.endDate,
                    ),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.lightText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.brown,
              size: 18,
            ),
          ],
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
        'Unable to load dashboard.',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.brown,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    paint.color = AppColors.borderPeach;
    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;

    const double dashWidth = 8;
    const double dashSpace = 6;

    final RRect roundedRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(24),
    );

    final Path path = Path();
    path.addRRect(roundedRect);

    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      double distance = 0;

      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(
          distance,
          distance + dashWidth,
        );

        canvas.drawPath(extractPath, paint);

        distance = distance + dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}