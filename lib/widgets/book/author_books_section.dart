import 'package:flutter/material.dart';
import '../../core/book_model.dart';
import '../../core/theme.dart';
import '../../core/app_icon.dart';

class AuthorBooksSection extends StatefulWidget {
  final String authorName;
  final String currentBookId;
  final Function(Book)? onBookTap;

  const AuthorBooksSection({
    super.key,
    required this.authorName,
    required this.currentBookId,
    this.onBookTap,
  });

  @override
  State<AuthorBooksSection> createState() => _AuthorBooksSectionState();
}

class _AuthorBooksSectionState extends State<AuthorBooksSection> {
  List<Book> authorBooks = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAuthorBooks();
  }

  Future<void> _loadAuthorBooks() async {
    // Inizio caricamento
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final books = await Book.getBooksByAuthor(
        widget.authorName,
        excludeBookId: widget.currentBookId,
      );

      if (!mounted) return;
      setState(() {
        authorBooks = books;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(25, 25, 25, 50),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey.shade300
              : AppTheme.lightSurface,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titolo
          Row(
            children: [
              Expanded(
                child: Text(
                  'Altri libri di ${widget.authorName}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.5),

          // Corpo
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage != null)
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  AppIcon(AppIconType.error),
                  const SizedBox(width: 12.5),
                  Expanded(
                    child: Text(
                      'Errore nel caricamento dei libri dell\'autore',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _loadAuthorBooks,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            )
          else if (authorBooks.isEmpty)
            Container(
              padding: const EdgeInsets.all(25),
              child: Row(
                children: [
                  AppIcon(AppIconType.info),
                  const SizedBox(width: 12.5),
                  Expanded(
                    child: Text(
                      'Nessun altro libro trovato per questo autore',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // Lista dei libri
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: authorBooks.length,
                itemBuilder: (context, index) {
                  final book = authorBooks[index];
                  return _buildBookCard(book);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookCard(Book book) {
    return GestureDetector(
      onTap: () => widget.onBookTap?.call(book),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Copertina
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: book.coverUrl.isNotEmpty
                      ? Image.network(
                          book.coverUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.white,
                              child: AppIcon(AppIconType.book),
                            );
                          },
                        )
                      : Container(
                          color: Colors.white,
                          child: AppIcon(AppIconType.book),
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
