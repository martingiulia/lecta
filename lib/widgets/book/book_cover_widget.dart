import 'package:flutter/material.dart';
import '../../core/book_model.dart';
import '../../core/theme.dart';
import '../../core/app_icon.dart';

/// Widget per la copertina del libro con Hero animation
class BookCoverWidget extends StatelessWidget {
  final Book book;
  final double? width;
  final double? height;

  const BookCoverWidget({
    super.key,
    required this.book,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'book-${book.id}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          height: height ?? 330,
          color: Theme.of(context).cardColor,
          child: book.coverUrl.isNotEmpty
              ? Image.network(
                  '${book.coverUrl}?w=500&h=750&quality=90',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Theme.of(context).cardColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderCover(context),
                )
              : _buildPlaceholderCover(context),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: AppTheme.primary, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(AppIconType.book, size: 50),
            const SizedBox(height: 8),
            Text(
              'Copertina\nnon disponibile',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withAlpha(100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
