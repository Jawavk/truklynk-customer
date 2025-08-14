import 'package:flutter/material.dart';
import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/pages/History/presentation/constants/history_theme.dart';
import 'package:truklynk/pages/History/presentation/screens/history_tab_bar.dart';
import 'package:truklynk/services/token_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  TokenService tokenService = TokenService();

  Future<Createuser?> getUser() async {
    return await tokenService.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //  Navigator.pushReplacementNamed(context, '/HomeScreen');

        return true; // Allows the back action
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: HistoryTheme.blackColor,
            backgroundColor: HistoryTheme.blackColor,
            title: FutureBuilder<Createuser?>(
              future: getUser(),
              builder: (context, snapshot) {
                print(snapshot);
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading...");
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('No user data found');
                }
                final user = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Hello ${user.name}!",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                    ),
                  ),
                );
              },
            ),
          ),
          body: const HistoryTabBar(),
        ),
      ),
    );
  }
}
