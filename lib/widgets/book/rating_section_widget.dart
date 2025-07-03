import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/book_model.dart';
import '../../providers/books_provider.dart';
import '../book/bottomsheet_screen.dart';
import '../../core/app_icon.dart';

/// Widget per la sezione valutazione personalizzata del libro
class RatingSectionWidget extends StatelessWidget {
  final Book book;

  const RatingSectionWidget({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Consumer<BooksProvider>(
      builder: (context, booksProvider, child) {
        final customRating = booksProvider.getCustomRating(book.id);
        final customEmoji = booksProvider.getCustomEmoji(book.id) ?? '⭐';
        final customComment = booksProvider.getCustomComment(book.id);

        // Se non c'è valutazione, mostra il bottone per aggiungerla
        if (customRating == null) {
          return const SizedBox.shrink();
        }

        // Se la valutazione esiste, mostra la valutazione e il bottone Rileggi
        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Contenitore principale
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.withValues(alpha: 0.3)
                          : AppTheme.lightSurface,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 25,
                      ), // Spazio per la chip "sospesa"
                      // Valutazione con emoji personalizzate e pulsante modifica
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Contenitore principale con le stelle
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Emoji della valutazione
                                ...List.generate(5, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Text(
                                      customEmoji,
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall
                                          ?.copyWith(
                                            color: index < customRating
                                                ? Colors.amber
                                                : Colors.grey.withValues(
                                                    alpha: 0.3,
                                                  ),
                                          ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          // Icona modifica posizionata in alto a destra
                          Positioned(
                            top: -8,
                            right: -8,
                            child: GestureDetector(
                              onTap: () async {
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) =>
                                      RatingBottomSheet(book: book),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primary,
                                    width: 1,
                                  ),
                                ),
                                child: AppIcon(
                                  AppIconType.edit,
                                  color: AppTheme.primary,
                                  size: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Commento (se presente)
                      if (customComment != null &&
                          customComment.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          customComment,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                      const SizedBox(height: 12.5),
                      // Bottone Rileggi

                      // Chip informative in basso
                      Wrap(alignment: WrapAlignment.center, spacing: 12.5),
                    ],
                  ),
                ),
                // Chip "La tua valutazione" posizionata sul bordo superiore
                Positioned(
                  top: -12,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'La tua valutazione',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
