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
      setState(() => _selectedIndex = index);
      context.go(widget.tabs[index].initialLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Color(0xFF313131), width: 1.0),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(widget.tabs.length, (i) {
                return _BottomBarItem(
                  icon: widget.tabs[i].icon,
                  label: widget.tabs[i].label ?? '',
                  isSelected: _selectedIndex == i,
                  primaryColor: primary,
                  onTap: () => _onItemTapped(i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final Icon icon;
  final String label;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? primaryColor : const Color(0xFF787878);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme(
              data: IconThemeData(color: color, size: 20),
              child: icon,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 9,
                  fontWeight:
                      isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NavBarItem {
  final String initialLocation;
  final Icon icon;
  final String? label;
  const NavBarItem({
    required this.initialLocation,
    required this.icon,
    this.label,
  });
}
