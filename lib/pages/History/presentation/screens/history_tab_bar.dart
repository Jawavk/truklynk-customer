import 'package:flutter/material.dart';
import 'package:truklynk/common/widgets/custom_tab_bar.dart';
import 'package:truklynk/pages/History/presentation/constants/history_theme.dart';
import 'package:truklynk/pages/History/presentation/screens/history_card.dart';

import '../../data/models/history_model.dart';

class HistoryTabBar extends StatefulWidget {
  const HistoryTabBar({super.key});

  @override
  State<HistoryTabBar> createState() => _HistoryTabBarState();
}

class _HistoryTabBarState extends State<HistoryTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<TabItem> tabs;

  @override
  void initState() {
    super.initState();
    tabs = [
      TabItem(index: 0, title: "Ongoing"),
      TabItem(index: 1, title: "Previous"),
    ];
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HistoryTheme.blackColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTabBar(
              tabs: tabs,
              tabController: _tabController,
              dividerColor: Colors.transparent,
              activeTabColor: Colors.black,
              indicatorColor: Colors.white,
              inactiveTabColor: Colors.white,
              tabWidth: 250,
            ),
          ),
          const SizedBox(height: 10),
          CustomTabBarView(
            tabViews: tabs.map((TabItem tab) {
              return HistoryCard(status: tab.index ?? 0);
            }).toList(),
            tabController: _tabController,
          ),
        ],
      ),
    );
  }
}
