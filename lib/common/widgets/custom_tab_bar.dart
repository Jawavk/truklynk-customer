import 'package:flutter/material.dart';
import 'package:truklynk/config/theme.dart';

import '../../pages/History/data/models/history_model.dart';

class CustomTabBar extends StatelessWidget {
  final List<TabItem> tabs;
  final TabController tabController;
  final Color? activeTabColor;
  final Color? inactiveTabColor;
  final Color? indicatorColor;
  final Color? dividerColor;
  final double? tabWidth;
  final TextStyle labelStyle;
  final double borderRadius;
  final void Function(int index)? onTabSelected;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.tabController,
    this.activeTabColor,
    this.inactiveTabColor,
    this.dividerColor,
    this.indicatorColor,
    this.tabWidth,
    this.labelStyle = const TextStyle(fontWeight: FontWeight.w600),
    this.borderRadius = 8.0,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.whiteColor.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TabBar(
        controller: tabController,
        isScrollable: tabs.length > 2,
        dividerColor: dividerColor,
        indicator: BoxDecoration(
          color: indicatorColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        labelColor: activeTabColor,
        labelStyle: labelStyle,
        unselectedLabelColor: inactiveTabColor,
        tabs: tabs.map((tab) {
          return Container(
            width: (tabs.length == 2)
                ? MediaQuery.of(context).size.width / tabs.length
                : tabWidth,
            alignment: Alignment.center,
            child: Tab(text: tab.title),
          );
        }).toList(),
        onTap: (index) {
          if (onTabSelected != null) {
            onTabSelected!(index); // Invoke callback with the selected index
          }
        },
      ),
    );
  }
}

class CustomTabBarView extends StatelessWidget {
  final List<Widget> tabViews;
  final TabController tabController;

  const CustomTabBarView({
    super.key,
    required this.tabViews,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TabBarView(
        controller: tabController,
        children: tabViews,
      ),
    );
  }
}
