import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:collection/collection.dart';

import '../core/book_model.dart';
import 'discover_screen.dart';
import 'challenges_screen.dart';
import 'goals_screen.dart';
import 'reading_timer_screen.dart';
import '../providers/books_provider.dart';
import '../widgets/book/book_cover_widget.dart';
import '../core/theme.dart';
import '../core/app_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BooksProvider>(
      builder: (context, booksProvider, child) {
        // Trova il libro in lettura con la sessione più recente
        final List<Book> reading = booksProvider.currentlyReading;
        Book? lastReadingBook;
        if (reading.isNotEmpty && booksProvider.lastReadBookId != null) {
          lastReadingBook = reading.firstWhereOrNull(
            (b) => b.id == booksProvider.lastReadBookId,
          );
          // Se non trovato, prendi il più recente per lastReadingSession
          lastReadingBook ??= reading.isNotEmpty
              ? (reading.length == 1
                    ? reading.first
                    : reading.reduce((a, b) {
                        final aTime = a.id == booksProvider.lastReadBookId
                            ? booksProvider.lastReadingSession ?? DateTime(0)
                            : DateTime(0);
                        final bTime = b.id == booksProvider.lastReadBookId
                            ? booksProvider.lastReadingSession ?? DateTime(0)
                            : DateTime(0);
                        return aTime.isAfter(bTime) ? a : b;
                      }))
              : null;
        }
        final bool showReading = lastReadingBook != null;
        return Scaffold(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppTheme.lightBackground
              : AppTheme.darkBackground,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Le tue letture',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: showReading
                ? _buildReadingLayout(context, booksProvider, lastReadingBook)
                : _buildEmptyLayout(context),
          ),
        );
      },
    );
  }

  Widget _buildReadingLayout(
    BuildContext context,
    BooksProvider booksProvider,
    Book book,
  ) {
    final double progress = booksProvider.getReadingProgress(
      book.id,
      book.pages,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        _buildCurrentReadingCard(
          context: context,
          book: book,
          progress: progress,
        ),
        _buildCommonBottomWidgets(context),
      ],
    );
  }

  Widget _buildCurrentReadingCard({
    required BuildContext context,
    required Book book,
    required double progress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 240),
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : null,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            book.title,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            book.author,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: AppTheme.lightSurface,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReadingTimerPage(
                            totalPages: book.pages,
                            bookId: book.id,
                          ),
                        ),
                      );
                    },
                    child: const Text("Nuova sessione di lettura", style: null),
                  ),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                BookCoverWidget(book: book, width: 200, height: 280),
                Positioned(
                  bottom: 12.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 180,
                      height: 12.5,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color.fromARGB(
                          95,
                          255,
                          255,
                          255,
                        ),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DiscoverScreen()),
              );
            },
            child: Container(
              width: 228,
              height: 285,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(
                    AppIconType.add,
                    size: 56,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(height: 12.5),
                  Text(
                    'Inizia il tuo primo libro',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Center(
          child: Column(
            children: [
              Text(
                'Nessuna lettura ancora tracciata',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12.5),
              Text(
                'I tuoi ultimi libri in corso e completati con attività di lettura appariranno qui.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
        _buildCommonBottomWidgets(context),
      ],
    );
  }

  Widget _buildCommonBottomWidgets(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showObjectivesDialog(context),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/images/tavola-obb-dark.png'
                            : 'assets/images/tavola-obb-light.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Text(
                          'I miei obiettivi',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 25),
        Expanded(
          child: GestureDetector(
            onTap: () => _showChallengesDialog(context),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    children: [
                      Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'assets/images/tavola-sfide-dark.png'
                            : 'assets/images/tavola-sfide-light.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Text(
                          'Le sfide del mese',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showObjectivesDialog(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ReadingGoalsPage()));
  }

  void _showChallengesDialog(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ChallengesPage()));
  }
}
