import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/book_model.dart';
import '../../screens/bookdetails_screen.dart';
import '../../widgets/book/book_cover_widget.dart';
import '../../providers/books_provider.dart';
import '../../core/app_icon.dart';

class FinishedBooksSection extends StatelessWidget {
  final List<Book> finished;
  final Map<String, int> customRatings;
  final String searchQuery;
  final String selectedGenre;

  const FinishedBooksSection({
    super.key,
    required this.finished,
    required this.customRatings,
    required this.searchQuery,
    required this.selectedGenre,
  });

  List<Book> get filteredBooks {
    final genreFiltered = selectedGenre == 'Tutti'
        ? finished
        : finished
              .where((book) => book.genres.contains(selectedGenre))
              .toList();

    if (searchQuery.isEmpty) return genreFiltered;

    return genreFiltered.where((book) {
      final titleMatch = book.title.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final authorMatch = book.author.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final genreMatch = book.genres.any(
        (genre) => genre.toLowerCase().contains(searchQuery.toLowerCase()),
      );
      return titleMatch || authorMatch || genreMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final booksToShow = filteredBooks;

    if (booksToShow.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text('Finiti', style: Theme.of(context).textTheme.bodyLarge),
        ),
        SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.5,
              crossAxisSpacing: 12.5,
              mainAxisSpacing: 12.5,
            ),
            itemCount: booksToShow.length,
            itemBuilder: (context, index) {
              final book = booksToShow[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 230, // O qualunque altezza desideri
                    width: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookDetailPage(bookId: book.id),
                            ),
                          );
                        },
                        child: BookCoverWidget(book: book),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        6,
                        12.5,
                        6,
                        12.5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<BooksProvider>(
                            builder: (context, booksProvider, child) {
                              final customEmoji = booksProvider.getCustomEmoji(
                                book.id,
                              );
                              final rating = customRatings[book.id] ?? 0;

                              // Se c'è un'emoji personalizzata, mostrala
                              if (customEmoji != null && rating > 0) {
                                return Row(
                                  children: List.generate(rating, (index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 2),
                                      child: Text(
                                        customEmoji,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge,
                                      ),
                                    );
                                  }),
                                );
                              } else {
                                // Altrimenti mostra le stelline classiche
                                return Row(
                                  children: List.generate(5, (starIndex) {
                                    return AppIcon(
                                      AppIconType.star,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }),
                                );
                              }
                            },
                          ),
                          SizedBox(height: 6),
                          Text(
                            book.title,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 12.5),
      ],
    );
  }
}
