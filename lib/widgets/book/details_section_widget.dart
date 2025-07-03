import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/book_model.dart';

/// Widget per la sezione dettagli del libro
class DetailsSectionWidget extends StatelessWidget {
  final Book book;

  const DetailsSectionWidget({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                  ? Colors.grey.shade300
                  : AppTheme.lightSurface,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 25), // Spazio per la chip "sospesa"
              // Lista dei dettagli
              ..._getBookDetails(book).entries.map(
                (entry) => _buildDetailRow(context, entry.key, entry.value),
              ),
              const SizedBox(height: 12.5),
              // Pulsanti in basso
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12.5,
                children: [
                  _buildDetailChip(
                    context,
                    '${book.publishDate?.year.toString().toUpperCase() ?? 'N/A'}\nAnno',
                  ),
                  _buildDetailChip(
                    context,
                    '${book.pages.toString().toUpperCase()}\nPagine',
                  ),
                  _buildDetailChip(
                    context,
                    '${book.language?.toUpperCase() ?? 'N/A'}\n Lingua',
                  ),
                ],
              ),
            ],
          ),
        ),
        // Chip "Dettagli" posizionata sul bordo superiore
        Positioned(
          top: -12,
          left: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12.5),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Dettagli',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.grey.shade200
            : AppTheme.lightSurface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        softWrap: true,
        overflow: TextOverflow.visible,
        maxLines: null,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black87
              : AppTheme.lightSurface,
        ),
      ),
    );
  }

  Map<String, String> _getBookDetails(Book book) {
    return {
      'Autore': book.author,
      'Editore': book.publisher ?? 'Non disponibile',
      'Genere': book.genre ?? 'Non disponibile',
    };
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey.shade600
                        : AppTheme.lightSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.grey.shade300
                : AppTheme.lightSurface,
          ),
        ],
      ),
    );
  }
}
