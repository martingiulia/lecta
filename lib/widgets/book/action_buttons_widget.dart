import 'package:flutter/material.dart';
import '/../../core/theme.dart';
import '/../../core/book_model.dart';
import 'package:provider/provider.dart';
import '../../providers/books_provider.dart';
import '../../screens/reading_timer_screen.dart';
import 'package:applecta/widgets/book/bottomsheet_screen.dart';

/// Widget per i pulsanti di azione (Leggi Ora, Salva in Libreria)
class ActionButtonsWidget extends StatelessWidget {
  final Book book;

  const ActionButtonsWidget({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    final status = booksProvider.getBookStatus(book.id);

    void startReadingSession() async {
      // Se il libro non è ancora in libreria, lo aggiungiamo automaticamente
      if (status == BookStatus.notInLibrary) {
        // Passiamo l'oggetto book al metodo startReading
        booksProvider.startReading(book.id, book);

        // CHECK MOUNTED prima di usare context
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Libro "${book.title}" aggiunto alla libreria e iniziato a leggere!',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (status == BookStatus.toRead) {
        // Il libro è già in _toRead, usiamo il metodo normale
        booksProvider.startReading(book.id, book);
      }
      // Se è già in currentlyReading, procediamo direttamente

      final page = await Navigator.of(context).push<int>(
        MaterialPageRoute(
          builder: (context) => ReadingTimerPage(
            totalPages: book.pages, // o book.pageCount
            bookId: book.id,
          ),
        ),
      );

      if (!context.mounted) return;

      if (page != null && page > 0) {
        try {
          await booksProvider.updateReadingPage(book.id, page);

          // 🚨 ALTRO CHECK MOUNTED DOPO AWAIT
          if (!context.mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Pagina aggiornata a $page')));
          Navigator.of(context).popUntil((route) => route.isFirst);
        } catch (e) {
          // Gestione errore senza context se non mounted
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Errore nell\'aggiornamento: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }

    final String buttonLabel = status == BookStatus.currentlyReading
        ? 'Continua a leggere'
        : 'Leggi Ora';

    if (status == BookStatus.finished) {
      final customRating = booksProvider.getCustomRating(book.id);
      // Se NON c'è valutazione, mostra "Aggiungi valutazione"
      if (customRating == null) {
        return Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Aggiungi valutazione',
                onTap: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    builder: (context) => RatingBottomSheet(book: book),
                  );
                },
              ),
            ),
            const SizedBox(width: 12.5),
            Expanded(
              child: _buildActionButton(
                context,
                'Rimuovi dalla Libreria',
                onTap: () {
                  booksProvider.removeFromLibrary(book.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Libro rimosso dalla libreria.')),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      } else {
        // Se la valutazione esiste, mostra "Rileggi"
        return Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Rileggi',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReadingTimerPage(
                        totalPages: book.pages,
                        bookId: book.id,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12.5),
            Expanded(
              child: _buildActionButton(
                context,
                'Rimuovi dalla Libreria',
                onTap: () {
                  booksProvider.removeFromLibrary(book.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Libro rimosso dalla libreria.')),
                  );
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      }
    }

    if (status == BookStatus.toRead || status == BookStatus.currentlyReading) {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              buttonLabel,
              onTap: startReadingSession,
            ),
          ),
          const SizedBox(width: 12.5),
          Expanded(
            child: _buildActionButton(
              context,
              'Rimuovi dalla Libreria',
              onTap: () {
                booksProvider.removeFromLibrary(book.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Libro rimosso dalla libreria.')),
                );
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    }

    // Caso: libro non in libreria (BookStatus.notInLibrary)
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context,
            buttonLabel,
            onTap: startReadingSession,
          ),
        ),
        const SizedBox(width: 12.5),
        Expanded(
          child: _buildActionButton(
            context,
            'Salva in Libreria',
            onTap: () {
              booksProvider.addToToRead(book);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Libro "${book.title}" salvato nella libreria!',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text, {
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            softWrap: true,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightSurface,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
