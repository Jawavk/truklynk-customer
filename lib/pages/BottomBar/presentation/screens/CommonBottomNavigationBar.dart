import 'package:flutter/material.dart';
import '../constants/bottombar_theme.dart';

class CommonBottomNavigationBar extends StatelessWidget {
  final List<Widget> pages;
  final List<BottomNavigationBarItem> navItems;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const CommonBottomNavigationBar({
    super.key,
    required this.pages,
    required this.navItems,
    required this.currentIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: List.generate(pages.length, (index) {
          return Visibility(
            visible: index == currentIndex,
            child: pages[index],
          );
        }),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final isSelected = currentIndex == index;
            return InkWell(
              borderRadius: BorderRadius.circular(100),
              splashColor: Colors.blue.withOpacity(0.1), // Adjust splash color
              onTap: () {
                onIndexChanged(index);
              },
              child: ClipOval(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: navItems[index].icon,
                      ),
                      if (isSelected)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: BottombarTheme.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
