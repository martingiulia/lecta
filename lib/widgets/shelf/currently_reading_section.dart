import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/book_model.dart';

import '../../widgets/book/book_cover_widget.dart';
import '../../screens/bookdetails_screen.dart';
import '../../providers/books_provider.dart';
import '../../core/theme.dart';

class CurrentlyReadingSection extends StatelessWidget {
  final List<Book> currentlyReading;
  final String searchQuery;
  final String selectedGenre;

  const CurrentlyReadingSection({
    super.key,
    required this.currentlyReading,
    required this.searchQuery,
    required this.selectedGenre,
  });

  List<Book> get filteredBooks {
    final genreFiltered = selectedGenre == 'Tutti'
        ? currentlyReading
        : currentlyReading
              .where((book) => book.genres.contains(selectedGenre))
              .toList();

    if (searchQuery.isEmpty) return genreFiltered;

    return genreFiltered.where((book) {
      final query = searchQuery.toLowerCase();
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.genres.any((genre) => genre.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final books = filteredBooks;
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);

    if (books.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12.5),
          child: Text(
            'Sto leggendo',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.90),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final double progress = booksProvider.getReadingProgress(
                book.id,
                book.pages,
              );

              return Padding(
                padding: const EdgeInsets.only(right: 12.5),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookDetailPage(bookId: book.id),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : null,
                      border: Border.all(
                        color: Colors.white,
                        width: Theme.of(context).brightness == Brightness.dark
                            ? 1
                            : 0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            height: 200,
                            child: BookCoverWidget(book: book),
                          ),
                          SizedBox(width: 25),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 12.5),
                                Text(
                                  book.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 12.5),
                                Text(
                                  book.author,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Spacer(),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${(progress * 100).toInt()}%',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(3),
                                      child: Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.primary,
                                            width: 2,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            backgroundColor: Colors.transparent,
                                            valueColor: AlwaysStoppedAnimation(
                                              AppTheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.5),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 25),
      ],
    );
  }
}
