import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/books_provider.dart';
import '../providers/book_detail_provider.dart';

import '../widgets/book/book_cover_widget.dart';
import '../widgets/book/book_info_widget.dart';
import '../widgets/book/format_tabs_widget.dart';
import '../widgets/book/plot_section_widget.dart';
import '../widgets/book/details_section_widget.dart';
import '../widgets/book/author_books_section.dart';
import '../widgets/book/action_buttons_widget.dart';
import '../widgets/book/rating_section_widget.dart';

/// Pagina di dettaglio del libro - versione refactorizzata
class BookDetailPage extends StatefulWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  @override
  void initState() {
    super.initState();
    // Carica i dettagli del libro quando la pagina si apre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BooksProvider>(
        context,
        listen: false,
      ).fetchBookById(widget.bookId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookDetailProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Text(
            'Dettagli sul libro',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
      actions: [
        Consumer<BooksProvider>(
          builder: (context, booksProvider, child) {
            final book = booksProvider.selectedBook;
            if (book == null) return Container();

            return IconButton(
              icon: Icon(
                booksProvider.isFavorite(book.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: booksProvider.isFavorite(book.id) ? Colors.red : null,
              ),
              onPressed: () {
                booksProvider.toggleFavorite(book);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<BooksProvider>(
      builder: (context, booksProvider, child) {
        if (booksProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (booksProvider.error != null) {
          return _buildErrorState(context, booksProvider);
        }

        final book = booksProvider.selectedBook;
        if (book == null) {
          return const Center(child: Text('Libro non trovato'));
        }

        // Cerca il libro nella libreria locale per avere lo stato aggiornato
        final localBook = booksProvider.finished.firstWhere(
          (b) => b.id == book.id,
          orElse: () => booksProvider.currentlyReading.firstWhere(
            (b) => b.id == book.id,
            orElse: () => booksProvider.toRead.firstWhere(
              (b) => b.id == book.id,
              orElse: () => book,
            ),
          ),
        );

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                BookCoverWidget(book: localBook),
                const SizedBox(height: 25),
                BookInfoWidget(book: localBook),
                const SizedBox(height: 50),
                const FormatTabsWidget(),
                const SizedBox(height: 25),
                ActionButtonsWidget(book: localBook),
                const SizedBox(height: 25),
                RatingSectionWidget(book: localBook),
                const SizedBox(height: 16),
                PlotSectionWidget(book: localBook),
                const SizedBox(height: 25),
                DetailsSectionWidget(book: localBook),
                const SizedBox(height: 25),

                AuthorBooksSection(
                  authorName: localBook.author,
                  currentBookId: localBook.id,
                  onBookTap: (selectedBook) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            BookDetailPage(bookId: selectedBook.id),
                      ),
                    );
                  },
                ),

                // Spazio finale
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, BooksProvider booksProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            booksProvider.error!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => booksProvider.fetchBookById(widget.bookId),
            child: Text(
              'Riprova',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
