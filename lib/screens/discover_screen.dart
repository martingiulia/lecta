import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../core/theme.dart';
import '../core/book_model.dart';
import '../providers/books_provider.dart';

import 'bookdetails_screen.dart';
import 'search_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

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
            Text('Esplora', style: Theme.of(context).textTheme.headlineMedium),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkSurface
                      : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.primary
                        : Colors.transparent,
                  ),
                ),
                child: Icon(
                  Platform.isAndroid ? Icons.search : CupertinoIcons.search,
                  size: 22.5,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
            ),
          ],
        ),
      ),
      body: const SafeArea(child: _DiscoverContent()),
    );
  }
}

class _DiscoverContent extends StatefulWidget {
  const _DiscoverContent();

  @override
  State<_DiscoverContent> createState() => _DiscoverContentState();
}

class _DiscoverContentState extends State<_DiscoverContent> {
  List<Book> featuredBooks = [];
  List<Book> thrillerBooks = [];
  List<Book> fantasyBooks = [];
  List<Book> romanceBooks = [];
  List<Book> sciFiBooks = [];
  List<Book> horrorBooks = [];
  List<Book> recommendedBooks = [];

  List<Book> adventurenovels = [];
  List<Book> dramabooks = [];
  List<Book> crimenovels = [];

  List<Book> classicliterature = [];
  List<Book> cookbooks = [];
  List<Book> graphicnovels = [];

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDiscoverData();
    });
  }

  Future<void> _loadDiscoverData() async {
    // Controlla se il widget è ancora montato prima di iniziare
    if (!mounted) return;

    if (mounted) {
      setState(() {
        isLoading = true;
        error = null;
      });
    }

    try {
      final booksProvider = Provider.of<BooksProvider>(context, listen: false);

      // Carica libri per ogni sezione
      await booksProvider.searchBooks('bestseller fiction');
      if (!mounted) return; // Controlla dopo ogni operazione asincrona
      featuredBooks = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('thriller books');
      if (!mounted) return;
      thrillerBooks = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('fantasy novels');
      if (!mounted) return;
      fantasyBooks = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('romance novels');
      if (!mounted) return;
      romanceBooks = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('science fiction');
      if (!mounted) return;
      sciFiBooks = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('horror books');
      if (!mounted) return;
      horrorBooks = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('recommended fiction');
      if (!mounted) return;
      recommendedBooks = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('adventure novels');
      if (!mounted) return;
      adventurenovels = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('drama books');
      if (!mounted) return;
      dramabooks = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('crime novels');
      if (!mounted) return;
      crimenovels = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('classic literature');
      if (!mounted) return;
      classicliterature = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('cookbooks');
      if (!mounted) return;
      cookbooks = booksProvider.books.take(12).toList();

      await booksProvider.searchBooks('graphic novels');
      if (!mounted) return;
      graphicnovels = booksProvider.books.take(12).toList();

      // Ultimo controllo prima di chiamare setState
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(error!, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadDiscoverData(),
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async => _loadDiscoverData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12.5),
            _BookSection(title: 'Libri in Evidenza', books: featuredBooks),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            // Sezioni per generi
            _BookSection(title: 'Thriller', books: thrillerBooks),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            _BookSection(title: 'Fantasy', books: fantasyBooks),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            _BookSection(title: 'Romance', books: romanceBooks),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            _BookSection(title: 'Sci-Fi', books: sciFiBooks),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            _BookSection(title: 'Horror', books: horrorBooks),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            _BookSection(title: 'Adventure', books: adventurenovels),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            _BookSection(title: 'Drama', books: dramabooks),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            _BookSection(title: 'Crime', books: crimenovels),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            _BookSection(title: 'Classics', books: classicliterature),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            _BookSection(title: 'Cookbooks', books: cookbooks),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            _BookSection(title: 'Graphic Novels', books: graphicnovels),
            Divider(color: AppTheme.primary, thickness: 1),
            const SizedBox(height: 25),

            _BookSection(title: 'Raccomandati per te', books: recommendedBooks),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

class _BookSection extends StatelessWidget {
  final String title;
  final List<Book> books;

  const _BookSection({required this.title, required this.books});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12.5),
        SizedBox(
          height: 350,
          child: books.isEmpty
              ? Center(
                  child: Text(
                    'Nessun libro disponibile',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    return _BookCard(book: books[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final Book book;

  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailPage(bookId: book.id),
          ),
        );
      },
      child: Container(
        height: 325,
        width: 155,
        margin: const EdgeInsets.only(right: 12.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 236,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: book.coverUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        '${book.coverUrl}?w=500&h=750&quality=90',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.book,
                              size: 48,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    )
                  : const Icon(Icons.book, size: 50, color: Colors.white),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.author,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (book.rating > 0)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            book.rating.toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
