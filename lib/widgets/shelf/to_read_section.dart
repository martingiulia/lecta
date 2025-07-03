import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../core/book_model.dart';

import '../../widgets/book/book_cover_widget.dart';
import '../../screens/bookdetails_screen.dart';

class ToReadSection extends StatefulWidget {
  final List<Book> toRead;
  final String selectedGenre;
  final String searchQuery;
  final ValueChanged<String>
  onGenreSelected; // puoi anche rimuoverlo se non usi qui i chip

  const ToReadSection({
    super.key,
    required this.toRead,
    required this.selectedGenre,
    required this.searchQuery,
    required this.onGenreSelected,
  });

  @override
  State<ToReadSection> createState() => _ToReadSectionState();
}

class _ToReadSectionState extends State<ToReadSection> {
  List<Book> getFilteredBooks() {
    // Qui non serve più il filtro per genere, perché ShelfPage già filtra la lista
    if (widget.searchQuery.isEmpty) return widget.toRead;

    final query = widget.searchQuery.toLowerCase();
    return widget.toRead.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.genres.any((genre) => genre.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBooks = getFilteredBooks();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            'Da Leggere',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        SizedBox(height: 25),

        // Rimosso filtro generi (chips) - è ora in ShelfPage
        if (filteredBooks.isEmpty)
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                SizedBox(
                  height: 250,
                  child: Center(
                    child: Lottie.asset(
                      'assets/animations/X3Apy4ZpCp.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 12.5),
                Text(
                  'Nessun libro da leggere.\nAggiungine uno per iniziare!',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: filteredBooks.length <= 3 ? 275 : 550,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 25),
              itemCount: (filteredBooks.length / 6).ceil(),
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * 6;
                final endIndex = (startIndex + 6).clamp(
                  0,
                  filteredBooks.length,
                );
                final pageBooks = filteredBooks.sublist(startIndex, endIndex);

                return Container(
                  width: MediaQuery.of(context).size.width - 50,
                  margin: EdgeInsets.only(
                    right: pageIndex < (filteredBooks.length / 6).ceil() - 1
                        ? 25
                        : 0,
                  ),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.4,
                      crossAxisSpacing: 12.5,
                      mainAxisSpacing: 25,
                    ),
                    itemCount: pageBooks.length,
                    itemBuilder: (context, index) {
                      final book = pageBooks[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookDetailPage(bookId: book.id),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: BookCoverWidget(book: book),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
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
                                    Text(
                                      book.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      book.author,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
