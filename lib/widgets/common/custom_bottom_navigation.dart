import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../../screens/home_screen.dart';
import '../../screens/shelf_screen.dart';
import '../../screens/discover_screen.dart';
import '../../screens/miniclubs_screen.dart';
import '../../screens/profile_screen.dart';
import '../../core/theme.dart';

class NavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Widget screen;

  const NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.screen,
  });
}

// Main App Structure
class BottomNavigationWidget extends StatefulWidget {
  const BottomNavigationWidget({super.key});

  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    ShelfPage(),
    DiscoverScreen(),
    BookClubPage(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

/// Widget personalizzato per la bottom navigation bar
class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavigation({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? AppTheme.lightSurface
            : AppTheme.darkSurface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap != null ? (index) => onTap!(index) : null,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[600]
              : AppTheme.lightSurface.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Platform.isAndroid ? Icons.home : CupertinoIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Platform.isAndroid
                    ? Icons.collections_bookmark
                    : CupertinoIcons.collections,
              ),
              label: 'Libreria',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Platform.isAndroid
                    ? Icons.explore
                    : CupertinoIcons.search_circle,
              ),
              label: 'Cerca',
            ),
            BottomNavigationBarItem(
              icon: Platform.isAndroid
                  ? ImageIcon(AssetImage('assets/images/3p_24.png'))
                  : Icon(CupertinoIcons.chat_bubble_2),
              label: 'Book Club',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Platform.isAndroid ? Icons.person : CupertinoIcons.person,
              ),
              label: 'Profilo',
            ),
          ],
        ),
      ),
    );
  }
}
