import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../profile/profile_screen.dart';
import '../trips/trips_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() {
    return _MainNavigationScreenState();
  }
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void changeScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void openTripsTab() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  Widget getCurrentScreen() {
    if (_selectedIndex == 0) {
      return HomeScreen(
        onViewAllTrips: openTripsTab,
      );
    } else if (_selectedIndex == 1) {
      return const TripsScreen();
    } else {
      return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getCurrentScreen(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(38),
            topRight: Radius.circular(38),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(38),
            topRight: Radius.circular(38),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: changeScreen,
            backgroundColor: AppColors.navBackground,
            selectedItemColor: AppColors.activeNav,
            unselectedItemColor: AppColors.inactiveNav,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                label: 'Trips',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}