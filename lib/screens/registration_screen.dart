import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../widgets/common/custom_bottom_navigation.dart';
import '../providers/onboarding_provider.dart';
import 'onboarding_screen.dart';

/// A registration screen that mirrors the "Create your Suno account" design
/// from the reference screenshot. Integrate it by adding a route like
///   '/register': (_) => const RegistrationScreen(),
/// to your `MaterialApp` routes map.
class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await url_launcher.canLaunchUrl(uri)) {
      await url_launcher.launchUrl(
        uri,
        mode: url_launcher.LaunchMode.externalApplication,
      );
    }
  }

  Widget _socialButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 30,
            color: isDark ? Colors.white : AppTheme.primary,
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final divider = Divider(
      color: isDark ? Colors.white24 : Colors.black12,
      thickness: 1,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Ink(
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              color: isDark ? Colors.white : AppTheme.primary,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                );
              },
              tooltip: 'Back',
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 150),

            Text(
              'Crea il tuo \naccount Lecta',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(color: AppTheme.darkSurface),
            ),

            const SizedBox(height: 50),

            // Primary action – phone number sign‑up
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.phone),
                label: const Text('Accedi con il numero di telefono'),
                onPressed: () {
                  context.read<OnboardingProvider>().completeLogin();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BottomNavigationWidget(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Divider with "or"
            Row(
              children: [
                Expanded(child: divider),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('oppure'),
                ),
                Expanded(child: divider),
              ],
            ),

            const SizedBox(height: 25),

            // Social buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _socialButton(context, Icons.email, () {
                  /* TODO: Email login */
                }),
                _socialButton(context, Icons.g_mobiledata, () {
                  /* TODO: Google login */
                }),
                _socialButton(context, Icons.facebook, () {
                  /* TODO: Facebook login */
                }),
                _socialButton(context, Icons.discord, () {
                  /* TODO: Discord login */
                }),
              ],
            ),

            const SizedBox(height: 130),

            // Terms & privacy disclaimer
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black,
                    ),
                    children: [
                      const TextSpan(text: 'Creando un account accetti i '),
                      TextSpan(
                        text: 'Termini di Servizio',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color(0xFFBF1363),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              _launchUrl('https://example.com/terms'),
                      ),
                      const TextSpan(text: ' e confermi di aver letto la '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Color(0xFFBF1363),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              _launchUrl('https://example.com/privacy'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
