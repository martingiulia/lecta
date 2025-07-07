import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/onboarding_provider.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/common/custom_bottom_navigation.dart';

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboardingProvider, child) {
        if (onboardingProvider.isLoading) {
          return const SplashScreen(); // Mostra loading
        }

        if (onboardingProvider.hasSeenOnboarding ||
            onboardingProvider.hasLoggedIn) {
          return const BottomNavigationWidget(); // Mostra l'app completa
        } else {
          return const OnboardingScreen(); // Mostra onboarding
        }
      },
    );
  }
}
