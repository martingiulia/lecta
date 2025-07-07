import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import '../../providers/book_detail_provider.dart';
import '../../core/theme.dart';
import '../../core/book_model.dart';

/// Widget per la sezione della trama del libro
class PlotSectionWidget extends StatelessWidget {
  final Book book;

  const PlotSectionWidget({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookDetailProvider>(
      builder: (context, provider, child) {
        String rawDescription = book.description.isNotEmpty
            ? book.description
            : 'Una descrizione coinvolgente di questo libro che catturerà l\'attenzione del lettore e lo invoglierà a scoprire di più sulla storia e sui personaggi che lo popolano.';

        // Se la descrizione è lunga e non è espansa, taglia il testo
        String displayedDescription;
        if (provider.isExpanded || rawDescription.length <= 350) {
          displayedDescription = rawDescription;
        } else {
          displayedDescription = '${rawDescription.substring(0, 350)}...';
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
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
                  const SizedBox(height: 20),
                  Html(
                    data: displayedDescription,
                    style: {
                      "body": Style(
                        fontSize: FontSize.medium,
                        lineHeight: LineHeight.number(1.5),
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    },
                  ),
                  if (rawDescription.length > 350)
                    GestureDetector(
                      onTap: () => provider.toggleExpanded(),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.5),
                        child: Text(
                          provider.isExpanded ? 'Mostra meno' : 'Mostra tutto',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
                  'Trama',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
