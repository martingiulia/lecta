// pages/discover_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/books_provider.dart';
import '../core/book_model.dart';
import 'bookdetails_screen.dart';
import '../core/theme.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../core/app_icon.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carica i libri quando la pagina si apre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BooksProvider>(context, listen: false).fetchBooks();
    });
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
        titleSpacing: 25,
        title: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cerca libri...',
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: AppIcon(AppIconType.search, size: 25),
                    ),
                    contentPadding: EdgeInsets.only(
                      left: 25,
                      top: 12.5,
                      bottom: 12.5,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.primary
                            : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.primary
                            : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: AppTheme.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkSurface
                        : AppTheme.lightSurface,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  onSubmitted: (value) {
                    Provider.of<BooksProvider>(
                      context,
                      listen: false,
                    ).searchBooks(value);
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: AppIcon(AppIconType.camera, size: 28),
              tooltip: 'Scannerizza ISBN',
              onPressed: () async {
                var result = await BarcodeScanner.scan();
                if (result.rawContent.isNotEmpty) {
                  final isbnQuery = 'isbn:${result.rawContent}';
                  _searchController.text = isbnQuery;
                  Provider.of<BooksProvider>(
                    context,
                    listen: false,
                  ).searchBooks(isbnQuery);
                }
              },
            ),
          ],
        ),
      ),
      body: Consumer<BooksProvider>(
        builder: (context, booksProvider, child) {
          if (booksProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (booksProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(AppIconType.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    booksProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => booksProvider.fetchBooks(),
                    child: Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          if (booksProvider.books.isEmpty) {
            return Center(
              child: Text(
                'Nessun libro trovato',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: booksProvider.books.length,
            itemBuilder: (context, index) {
              final book = booksProvider.books[index];
              return BookCard(
                book: book,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailPage(bookId: book.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.5, horizontal: 0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: book.coverUrl.isNotEmpty
                      ? Image.network(
                          book.coverUrl,
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 150,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppTheme.darkSurface
                                  : AppTheme.lightSurface,
                              child: AppIcon(AppIconType.book, size: 50),
                            );
                          },
                        )
                      : Container(
                          width: 100,
                          height: 150,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkSurface
                              : AppTheme.lightSurface,
                          child: AppIcon(AppIconType.book, size: 50),
                        ),
                ),
                SizedBox(width: 25),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Text(
                        book.author,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(color: AppTheme.primary, thickness: 1), // linea di divisione
      ],
    );
  }
}
