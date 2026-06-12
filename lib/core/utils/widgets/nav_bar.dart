import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavBar extends StatefulWidget {
  final Widget child;
  final List<NavBarItem> tabs;
  const NavBar({super.key, required this.child, required this.tabs});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index < widget.tabs.length) {
      setState(() {
        _selectedIndex = index;
      });
      context.go(widget.tabs[index].initialLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: widget.tabs
            .map((tab) => BottomNavigationBarItem(
                  icon: tab.icon,
                  label: tab.label ?? '',
                ))
            .toList(),
      ),
    );
  }
}

class NavBarItem {
  final String initialLocation;
  final Icon icon;
  final String? label;
  const NavBarItem({required this.initialLocation, required this.icon, this.label});
}
