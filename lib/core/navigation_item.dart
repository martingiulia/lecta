import 'package:flutter/material.dart';

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
