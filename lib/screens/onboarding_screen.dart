import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/onboarding_provider.dart';
import '../core/theme.dart';

/// Schermata di onboarding per i nuovi utenti con video background
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  VideoPlayerController? _controller;
  bool _isVideoInitialized = false;
  String? _currentVideoPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVideo();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Determina il video da usare in base al tema
    String videoPath = Theme.of(context).brightness == Brightness.dark
        ? 'assets/videos/sfondogradient_dark.mp4'
        : 'assets/videos/sfondogradient_light.mp4';

    // Se il tema è cambiato, reinizializza il video
    if (_currentVideoPath != videoPath) {
      _currentVideoPath = videoPath;
      _initializeVideo();
    }
  }

  void _initializeVideo() async {
    if (_currentVideoPath == null) return;

    // Disponi del controller precedente se esiste
    await _controller?.dispose();

    try {
      _controller = VideoPlayerController.asset(_currentVideoPath!);
      await _controller!.initialize();

      // Configura il video
      _controller!.setLooping(true);
      _controller!.setVolume(0); // Senza audio
      _controller!.play();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      // In caso di errore, usa l'immagine di fallback
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  Widget _buildBackground() {
    if (_isVideoInitialized && _controller != null) {
      // Mostra il video background
      return Positioned.fill(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.size.width,
            height: _controller!.value.size.height,
            child: VideoPlayer(_controller!),
          ),
        ),
      );
    } else {
      // Fallback all'immagine statica
      String backgroundImage = Theme.of(context).brightness == Brightness.dark
          ? 'assets/images/sfondo-dark.png'
          : 'assets/images/sfondo-light.png';

      return Positioned.fill(
        child: Image.asset(backgroundImage, fit: BoxFit.cover),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video o immagine di background
          _buildBackground(),

          // Contenuto principale
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Il posto\nper i tuoi libri   ',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Organizza e innamorati (di nuovo) dei tuoi libri, uno scaffale digitale alla volta.',
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 55),

                  Consumer<OnboardingProvider>(
                    builder: (context, onboardingProvider, child) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            onboardingProvider.completeOnboarding();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Scopri Lecta',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
