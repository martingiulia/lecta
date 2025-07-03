import 'package:applecta/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/books_provider.dart';
import '../widgets/shelf/currently_reading_section.dart';
import '../widgets/shelf/finished_books_section.dart';
import '../widgets/shelf/to_read_section.dart';
import '../core/app_icon.dart';

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key});

  @override
  _ShelfPageState createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage> {
  String selectedGenre = 'Tutti';
  String searchQuery = '';

  bool _hasFilteredCurrentlyReading(BooksProvider provider, String query) {
    if (provider.currentlyReading.isEmpty) return false;
    if (query.isEmpty) return true;

    return provider.currentlyReading.any(
      (book) =>
          book.title.toLowerCase().contains(query.toLowerCase()) ||
          book.author.toLowerCase().contains(query.toLowerCase()),
    );
  }

  bool _hasFilteredFinished(BooksProvider provider, String query) {
    if (provider.finished.isEmpty) return false;
    if (query.isEmpty) return true;

    return provider.finished.any(
      (book) =>
          book.title.toLowerCase().contains(query.toLowerCase()) ||
          book.author.toLowerCase().contains(query.toLowerCase()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppTheme.lightBackground
          : AppTheme.darkBackground,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Text('Libreria', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      body: SafeArea(
        child: Consumer<BooksProvider>(
          builder: (context, booksProvider, child) {
            // Ricavo generi dinamici dai libri To Read
            final Set<String> dynamicGenres = {};
            for (final book in booksProvider.toRead) {
              dynamicGenres.addAll(book.genres);
            }
            dynamicGenres.removeWhere((genre) => genre.isEmpty);
            final List<String> genres = ['Tutti', ...dynamicGenres];

            // Filtra libri To Read con selezione attuale
            final filteredToRead = booksProvider.toRead.where((book) {
              final matchesGenre =
                  selectedGenre == 'Tutti' ||
                  book.genres.contains(selectedGenre);
              final matchesQuery =
                  searchQuery.isEmpty ||
                  book.title.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ||
                  book.author.toLowerCase().contains(searchQuery.toLowerCase());
              return matchesGenre && matchesQuery;
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(25),
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cerca titoli, autori..',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: AppIcon(
                            AppIconType.search,
                            color: Colors.grey,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: AppTheme.lightSurface,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: AppTheme.lightSurface,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: AppTheme.lightSurface,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkSurface
                            : AppTheme.lightSurface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12.5,
                        ),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                // Lista orizzontale con i generi spostata qui
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: genres.length,
                      itemBuilder: (context, index) {
                        final genre = genres[index];
                        final isSelected = selectedGenre == genre;
                        return Container(
                          margin: EdgeInsets.only(right: 12.5),
                          child: FilterChip(
                            label: Text(
                              genre,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : (Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black87),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedGenre = genre;
                              });
                            },
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.transparent
                                : Colors.white,
                            selectedColor: AppTheme.primary,
                            checkmarkColor: Colors.white,
                            side: BorderSide(color: AppTheme.primary),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 12.5),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Currently Reading Section + spazio
                        if (_hasFilteredCurrentlyReading(
                          booksProvider,
                          searchQuery,
                        )) ...[
                          CurrentlyReadingSection(
                            currentlyReading: booksProvider.currentlyReading,
                            searchQuery: searchQuery,
                            selectedGenre: selectedGenre,
                          ),
                        ],

                        // To Read Section + spazio
                        if (filteredToRead.isNotEmpty) ...[
                          ToReadSection(
                            toRead: filteredToRead,
                            searchQuery: searchQuery,
                            selectedGenre: selectedGenre,
                            onGenreSelected: (genre) {},
                          ),
                        ],

                        // Finished Books Section + spazio
                        if (_hasFilteredFinished(
                          booksProvider,
                          searchQuery,
                        )) ...[
                          FinishedBooksSection(
                            finished: booksProvider.finished,
                            customRatings: booksProvider.customRatings,
                            searchQuery: searchQuery,
                            selectedGenre: selectedGenre,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
