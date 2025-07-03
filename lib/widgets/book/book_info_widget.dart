import 'package:flutter/material.dart';
import '../../core/book_model.dart';
import '../../core/app_icon.dart';

/// Widget per le informazioni principali del libro (titolo, autore, rating, pagine)
class BookInfoWidget extends StatelessWidget {
  final Book book;

  const BookInfoWidget({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(book.author, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12.5),
        Text(
          book.title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12.5),
        // Rating e pagine
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(AppIconType.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              book.rating.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(width: 16),
            AppIcon(AppIconType.book, color: Colors.grey[600], size: 20),
            const SizedBox(width: 4),
            Text(
              '${book.pages} pagine',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
