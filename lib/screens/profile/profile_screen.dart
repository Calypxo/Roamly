import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void showLogoutDialog(BuildContext context) {
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
              'assets/images/logout_duck.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.logout_rounded,
                  color: AppColors.profileDarkBrown,
                  size: 55,
                );
              },
            ),
          ),
        ),
      ),
      title: 'Logout?',
      desc: 'Are you sure you want to logout from Roamly?',
      btnCancelText: 'Cancel',
      btnOkText: 'Logout',
      btnOkColor: AppColors.profileMainBrown,
      btnCancelOnPress: () {},
      btnOkOnPress: () async {
        await context.read<AuthProvider>().logout();
      },
    ).show();
  }

  String getUserEmail(BuildContext context) {
    AuthProvider authProvider;

    authProvider = context.watch<AuthProvider>();

    final user = authProvider.getCurrentUser();

    if (user == null) {
      return 'No email found';
    }

    if (user.email == null) {
      return 'No email found';
    }

    return user.email!;
  }

  String getUserName(BuildContext context) {
    AuthProvider authProvider;

    authProvider = context.watch<AuthProvider>();

    final user = authProvider.getCurrentUser();

    if (user == null) {
      return 'traveler';
    }

    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }

    if (user.email != null && user.email!.trim().isNotEmpty) {
      return user.email!.split('@')[0];
    }

    return 'traveler';
  }

  String getFriendCode(String email) {
    String cleanedEmail;

    cleanedEmail = email.replaceAll('@', '');
    cleanedEmail = cleanedEmail.replaceAll('.', '');

    if (cleanedEmail.length >= 8) {
      return cleanedEmail.substring(0, 8).toUpperCase();
    }

    return cleanedEmail.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    String email;
    String userName;
    String friendCode;

    email = getUserEmail(context);
    userName = getUserName(context);
    friendCode = getFriendCode(email);

    return Scaffold(
      backgroundColor: AppColors.bigCard,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            children: [
              buildTitle(),
              const SizedBox(height: 10),
              buildProfileCard(userName: userName, friendCode: friendCode),
              const SizedBox(height: 18),
              buildReadyCard(),
              const SizedBox(height: 18),
              buildCollectionTitle(),
              const SizedBox(height: 10),
              buildCollectionCard(),
              const SizedBox(height: 18),
              buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() {
    return const Center(
      child: Text(
        'Profile',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.brown,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 4,
        ),
      ),
    );
  }

  Widget buildProfileCard({
    required String userName,
    required String friendCode,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 18),
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              buildMainInfoRow(userName: userName, friendCode: friendCode),
              const SizedBox(height: 20),
              buildDetailsRows(),
              const SizedBox(height: 18),
              buildTabs(),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            height: 34,
            width: 86,
            decoration: BoxDecoration(
              color: AppColors.profileMainBrown,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.profileDarkBrown,
                  offset: Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMainInfoRow({
    required String userName,
    required String friendCode,
  }) {
    return Row(
      children: [
        buildAvatar(),
        const SizedBox(width: 14),
        Expanded(
          child: buildUserInfo(userName: userName, friendCode: friendCode),
        ),
      ],
    );
  }

  Widget buildAvatar() {
    return Container(
      height: 96,
      width: 96,
      decoration: BoxDecoration(
        color: AppColors.expenseField,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/images/profile_avatar.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person_rounded,
              color: AppColors.brown,
              size: 55,
            );
          },
        ),
      ),
    );
  }

  Widget buildUserInfo({required String userName, required String friendCode}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Roamly',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            height: 1,
          ),
        ),
        const Text(
          'Traveler',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            height: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          userName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.profileLightBrown,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'FRIEND CODE',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.profileLightBrown,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          friendCode,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.brown,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget buildDetailsRows() {
    return Column(
      children: [
        buildDetailRow(label: 'ROLE', value: 'Trip planner'),
        const SizedBox(height: 10),
        buildDetailRow(label: 'STYLE', value: 'Cozy traveler'),
        const SizedBox(height: 10),
        buildDetailRow(label: 'GOAL', value: 'Spend wisely'),
      ],
    );
  }

  Widget buildDetailRow({required String label, required String value}) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.profileLightBrown,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.profileLightBrown,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTabs() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.inactiveCategory,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          buildTab(title: 'ABOUT', isSelected: false),
          buildTab(title: 'DETAILS', isSelected: true),
          buildTab(title: 'TRAITS', isSelected: false),
        ],
      ),
    );
  }

  Widget buildTab({required String title, required bool isSelected}) {
    Color backgroundColor;

    if (isSelected == true) {
      backgroundColor = AppColors.bigCard;
    } else {
      backgroundColor = Colors.transparent;
    }

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: AppColors.profileLightBrown,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildReadyCard() {
    return CustomPaint(
      foregroundPainter: ProfileDashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/profile_ready.png',
              height: 72,
              width: 72,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: AppColors.membersCard,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.travel_explore_rounded,
                    color: AppColors.brown,
                    size: 38,
                  ),
                );
              },
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready for your\nnext trip?',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.brown,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Plan, budget, and\ntravel cozy.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.profileLightBrown,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCollectionTitle() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Traveler Collection',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: AppColors.brown,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
        ),
      ),
    );
  }

  Widget buildCollectionCard() {
    return CustomPaint(
      foregroundPainter: ProfileDashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: buildCollectionItem(
                imagePath: 'assets/images/profile_itinerary.png',
                fallbackIcon: Icons.fact_check_outlined,
                label: 'Itinerary',
              ),
            ),
            Expanded(
              child: buildCollectionItem(
                imagePath: 'assets/images/profile_budget.png',
                fallbackIcon: Icons.account_balance_wallet_outlined,
                label: 'Budget',
              ),
            ),
            Expanded(
              child: buildCollectionItem(
                imagePath: 'assets/images/profile_trip.png',
                fallbackIcon: Icons.map_rounded,
                label: 'Trip',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCollectionItem({
    required String imagePath,
    required IconData fallbackIcon,
    required String label,
  }) {
    return Column(
      children: [
        Image.asset(
          imagePath,
          height: 60,
          width: 90,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              fallbackIcon,
              color: AppColors.profileMainBrown,
              size: 34,
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.profileLightBrown,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: () {
          showLogoutDialog(context);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.errorRed, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: AppColors.errorRed,
              size: 19,
            ),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: AppColors.errorRed,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileDashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    paint.color = AppColors.borderPeach;
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;

    const double dashWidth = 6;
    const double dashSpace = 5;

    final RRect roundedRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
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
