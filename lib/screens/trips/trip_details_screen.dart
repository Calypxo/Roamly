import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../models/trip_model.dart';
import '../../providers/trip_provider.dart';
import '../expenses/expenses_screen.dart';
import '../itinerary/itinerary_screen.dart';
import 'create_trip_screen.dart';

class TripDetailsScreen extends StatelessWidget {
  final TripModel trip;

  const TripDetailsScreen({
    super.key,
    required this.trip,
  });

  String formatDateRange(DateTime startDate, DateTime endDate) {
    DateFormat formatter;

    formatter = DateFormat('MMMM d, yyyy');

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

  double computeGroupShare() {
    if (trip.members <= 0) {
      return trip.totalBudget;
    }

    return trip.totalBudget / trip.members;
  }

  String getTripImagePath() {
    String imagePath;

    imagePath = trip.imagePath;

    if (imagePath.trim().isEmpty) {
      imagePath = 'assets/images/trip_cover_1.png';
    }

    return imagePath;
  }

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  void goToEditTrip(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return CreateTripScreen(
            tripToEdit: trip,
          );
        },
      ),
    );
  }

  void goToExpensesScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ExpensesScreen(
            trip: trip,
          );
        },
      ),
    );
  }

  void goToItineraryScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ItineraryScreen(
            trip: trip,
          );
        },
      ),
    );
  }

  void showMembersDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'Members',
      desc: 'Invite friends to share the expenses and plan the trip together.',
      btnOkText: 'Okay',
      btnOkColor: AppColors.brown,
      btnOkOnPress: () {},
    ).show();
  }

  void showDeleteDialog(BuildContext context) {
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
      title: 'Delete Trip?',
      desc: 'Are you sure you want to delete this trip? This action cannot be undone.',
      btnCancelText: 'Cancel',
      btnOkText: 'Delete',
      btnOkColor: AppColors.errorRed,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        deleteTrip(context);
      },
    ).show();
  }

  Future<void> deleteTrip(BuildContext context) async {
    TripProvider tripProvider;

    tripProvider = context.read<TripProvider>();

    bool success;

    success = await tripProvider.deleteTrip(trip.id);

    if (!context.mounted) {
      return;
    }

    if (success == true) {
      Navigator.pop(context);
    } else {
      showErrorDialog(
        context,
        tripProvider.getErrorMessage(),
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
    TripProvider tripProvider;

    tripProvider = context.watch<TripProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 18, 32, 28),
          child: Column(
            children: [
              buildTopBar(context),
              const SizedBox(height: 18),
              buildConnectedTripHeader(context),
              const SizedBox(height: 28),
              buildFeatureCards(context),
              const SizedBox(height: 26),
              buildDeleteButton(
                context,
                tripProvider.getIsLoading(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            goBack(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.brown,
          ),
        ),
        const Expanded(
          child: Text(
            'Trip Details',
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
        IconButton(
          onPressed: () {
            goToEditTrip(context);
          },
          icon: const Icon(
            Icons.edit_rounded,
            color: AppColors.brown,
          ),
        ),
      ],
    );
  }

  Widget buildConnectedTripHeader(BuildContext context) {
    double screenWidth;
    double headerWidth;

    screenWidth = MediaQuery.of(context).size.width;
    headerWidth = screenWidth - 10;

    return Center(
      child: SizedBox(
        width: headerWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: headerWidth,
              child: buildTripImage(headerWidth),
            ),
            Container(
              width: headerWidth,
              margin: const EdgeInsets.only(top: 120),
              child: buildTripInfoCard(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTripImage(double imageWidth) {
    return Container(
      width: imageWidth,
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        image: DecorationImage(
          image: AssetImage(getTripImagePath()),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildTripInfoCard(BuildContext context) {
    String notesText;

    if (trip.notes.trim().isEmpty) {
      notesText = 'No notes added for this trip.';
    } else {
      notesText = trip.notes;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: BoxDecoration(
        color: AppColors.inactiveCategory,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderPeach,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTripNameRow(context),
          const SizedBox(height: 8),
          Text(
            formatDateRange(
              trip.startDate,
              trip.endDate,
            ),
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.groups_2_outlined,
                    color: AppColors.brown,
                    size: 30,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${trip.members} Members',
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
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Group Budget',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.brown,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Text(
                    formatBudget(trip.totalBudget),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.brown,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Your Initial Share',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.brown,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Text(
                    formatBudget(computeGroupShare()),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.brown,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Personal Budget',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.brown,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  Text(
                    formatBudget(trip.personalBudget),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.brown,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.borderPeach,
          ),
          const SizedBox(height: 18),
          const Text(
            'Notes',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notesText,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTripNameRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            trip.tripName,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.brown,
              fontSize: 23,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              height: 1,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            goToEditTrip(context);
          },
          icon: const Icon(
            Icons.more_vert_rounded,
            color: AppColors.brown,
          ),
        ),
      ],
    );
  }

  Widget buildFeatureCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: buildFeatureCard(
            title: 'Itinerary',
            imagePath: 'assets/images/itinerary_icon.png',
            color: AppColors.itineraryCard,
            onTap: () {
              goToItineraryScreen(context);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: buildFeatureCard(
            title: 'Budget',
            imagePath: 'assets/images/budget_icon.png',
            color: AppColors.budgetCard,
            onTap: () {
              goToExpensesScreen(context);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: buildFeatureCard(
            title: 'Members',
            imagePath: 'assets/images/members_icon.png',
            color: AppColors.membersCard,
            onTap: () {
              showMembersDialog(context);
            },
          ),
        ),
      ],
    );
  }

  Widget buildFeatureCard({
    required String title,
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderPeach,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    getFallbackIcon(title),
                    color: AppColors.brown,
                    size: 36,
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.brown,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getFallbackIcon(String title) {
    if (title == 'Itinerary') {
      return Icons.fact_check_outlined;
    } else if (title == 'Budget') {
      return Icons.attach_money_rounded;
    } else {
      return Icons.groups_2_outlined;
    }
  }

  Widget buildDeleteButton(BuildContext context, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: isLoading
            ? null
            : () {
          showDeleteDialog(context);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AppColors.errorRed,
            width: 1.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            color: AppColors.errorRed,
            strokeWidth: 2.4,
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: AppColors.errorRed,
            ),
            SizedBox(width: 10),
            Text(
              'Delete Trip',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.errorRed,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}