import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/pages/BottomBar/bloc/bottombar_block.dart';
import 'package:truklynk/pages/BottomBar/bloc/bottombar_event.dart';
import 'package:truklynk/pages/BottomBar/bloc/bottombar_state.dart';
import 'package:truklynk/pages/BottomBar/presentation/screens/CommonBottomNavigationBar.dart';
import 'package:truklynk/pages/History/presentation/screens/history.dart';
import 'package:truklynk/pages/Home/presentation/screens/home.dart';
import 'package:truklynk/pages/Profile/presentation/screens/profile.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<BottomNavBarBloc>(
        create: (context) =>
            BottomNavBarBloc(), // Ensure a new instance of BottomNavBarBloc
        child: BlocConsumer<BottomNavBarBloc, BottombarState>(
          listener: (context, state) {
            // Listener to react to state changes (if needed)
          },
          builder: (context, state) {
            final int currentIndex = state.currentIndex;
            List<BottomNavigationBarItem> navItems = [
              _buildNavItem('assets/images/Home.png', 0, currentIndex),
              _buildNavItem('assets/images/Feed.png', 1, currentIndex),
              // _buildNavItem(
              //     'assets/images/notification-3.png', 2, currentIndex),
              _buildNavItem('assets/images/Profile.png', 2, currentIndex),
              // _buildNavItem('assets/images/Auto-added.png', 4, currentIndex),
            ];

            return CommonBottomNavigationBar(
              pages: [
                const HomeScreen(),
                const HistoryScreen(),
                // _workingProgress(),
                const Profile(),
                // _workingProgress(), // Replace with your actual Cart page widget
              ],
              navItems: navItems,
              currentIndex: currentIndex,
              onIndexChanged: (index) {
                BlocProvider.of<BottomNavBarBloc>(context)
                    .add(BottomNavBar(index: index));
              },
            );
          },
        ));
  }

  BottomNavigationBarItem _buildNavItem(
      String assetPath, int index, int currentIndex) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        assetPath,
        width: 24,
        height: 24,
        color: currentIndex == index ? Colors.red : Colors.grey,
      ),
      label: '', // Non-null label
    );
  }

  Widget _workingProgress() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '🚧 Work in Progress! \n\nThis feature is coming soon. Stay tuned for updates!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }
}
